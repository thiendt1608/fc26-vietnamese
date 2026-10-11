# BÁO CÁO NGHIÊN CỨU & XỬ LÝ TOÀN DIỆN CƠ SỞ DỮ LIỆU EA SPORTS FC 26
**Dự án:** Việt hóa & Tối ưu hóa Database Đội hình Việt Nam (Bình Tân FC) trong Career Mode  
**Công cụ phân tích:** FC 26 Live Editor (Lua Engine API), Python Binary & Minidump Parsers, Capstone Disassembly  
**Môi trường thử nghiệm:** EA SPORTS FC 26 (Engine Frostbite, Denuvo Protected, Windows 11 x64)

---

## 1. TỔNG QUAN BỐI CẢNH & MỤC TIÊU DỰ ÁN

### 1.1. Mục tiêu ban đầu: Việt hóa không lỗi Font UTF-8 đa byte
- Phương thức mod truyền thống của các bản mod FIFA/FC là đóng gói file `.fifamod` thông qua FIFA Editor Tool (FET) để ghi đè vào file database `eng_us.db`.
- **Nhược điểm chí mạng:** Thuật toán nén của FET khi đóng gói các chuỗi tiếng Việt có dấu (`ơ`, `ư`, `ắ`, `ễ`...) thường gây lỗi mã hóa UTF-8 đa byte, khiến font trong game hiển thị thành các ô vuông hoặc ký tự rác.
- **Giải pháp kỹ thuật của dự án:** Can thiệp trực tiếp ở cấp độ RAM khi game khởi chạy bằng cách nạp các file script Lua trong thư mục autorun của FC 26 Live Editor (`C:\FC 26 Live Editor\lua\autorun\`), gọi trực tiếp hàm API C++ `SetGameLocString(stringid, text)` để ghi đè hơn 70.000 chuỗi bản địa hóa tiếng Việt chuẩn NFC vào bộ nhớ game mà không cần nén lại file `.db`.

### 1.2. Sự cố phát sinh: Xung đột Đội hình & Crash trong Career Mode
Trong quá trình trải nghiệm Career Mode với đội bóng mod **Bình Tân FC** (`Team ID: 115486`) và dàn 29 cầu thủ Việt Nam (`Player ID: 900` đến `928`):
1. Khi thực hiện các thao tác chuyển nhượng cầu thủ giữa Bình Tân FC và Barcelona qua các script can thiệp thô vào bảng liên kết, dữ liệu trong file save Career Mode (`.CM`) bị xáo trộn nghiêm trọng.
2. **Triệu chứng 1:** Trong màn hình *Quản lý đội hình (Team Management / Squad)*, danh sách cầu thủ bị nhân đôi (Duplicate) gấp 2 lần, mỗi cầu thủ xuất hiện 2 thẻ bài song song, kéo giãn giao diện và làm văng game (Crash) lập tức khi thao tác.
3. **Triệu chứng 2:** Khi bấm *Vào trận đấu (Play Match)* hoặc *Mô phỏng trận đấu (Simulate Match)* (điển hình là trận vòng bảng UEFA Champions League gặp FC Bayern München), game bị văng (Crash desktop) ngay tức thì.

---

## 2. NGHIÊN CỨU KIẾN TRÚC LIVE EDITOR & CƠ SỞ DỮ LIỆU GAME (REVERSE ENGINEERING)

Để giải quyết triệt để vấn đề mà không đoán mò, chúng tôi đã tiến hành đào sâu kiến trúc mã nguồn và thư viện nội bộ của FC 26 Live Editor (`FCLiveEditor.DLL` và `System/le/lua`):

```
┌─────────────────────────────────────────────────────────────┐
│                 Frostbite Game Engine (RAM)                 │
│                      (FC26.exe Process)                     │
└──────────────────────────────▲──────────────────────────────┘
                               │
                Hooks / Memory Read & Write
                               │
┌──────────────────────────────┴──────────────────────────────┐
│                    FCLiveEditor.DLL (C++)                   │
│  - GetDBMeta()           -> Danh sách 236 bảng Database     │
│  - GetDBTableRows()      -> Đọc dữ liệu thô từng bảng       │
│  - EditDBTableField()    -> Commit dữ liệu trực tiếp vào RAM│
│  - InsertDBTableRow()    -> Thêm dòng mới vào bảng C++      │
└──────────────────────────────▲──────────────────────────────┘
                               │
                       Lua Engine Scripts
                               │
┌──────────────────────────────┴──────────────────────────────┐
│                 Engine Phân tích & Tự động                  │
│  - dump_all_tables_and_fk_analysis.lua (Quét 236 bảng)      │
│  - fix_database_permanently.lua (Chuẩn hóa DB & Commit)     │
│  - fix_career_growth_and_ranking.lua (Điền đủ 29 cầu thủ)   │
└─────────────────────────────────────────────────────────────┘
```

### 2.1. Khám phá 236 bảng Database thông qua `GetDBMeta()`
- Trước đây các script thông thường chỉ truy cập được khoảng 12 bảng phổ biến do gọi hàm `GetDBTableNames()` vốn trả về danh sách hạn chế hoặc `nil`.
- Qua việc phân tích nhị phân thư viện `libs/v2/imports/t3db/db.lua` và DLL nội bộ, chúng tôi phát hiện Live Editor sở hữu hàm `GetDBMeta()`.
- Hàm này trích xuất từ điển `meta.shortname_name_tables_map` ánh xạ các mã 4 ký tự nội bộ của game sang tên thật của **236 bảng Database** trong RAM.
- Chúng tôi đã xây dựng script `dump_all_tables_and_fk_analysis.lua` để quét toàn bộ 236 bảng và lọc ra **62 bảng có chứa Khóa Ngoại (Foreign Keys)** liên quan đến Bình Tân FC (`115486`), ĐTQG Việt Nam (`111527`) và 29 cầu thủ Việt Nam (`900 - 928`).

### 2.2. Cơ chế Commit dữ liệu: Phát hiện sự khác biệt giữa gán biến và `EditDBTableField()`
- **Phát hiện quan trọng:** Khi gọi `local rows = GetDBTableRows("tableName")`, Live Editor trả về một bảng Lua chứa các đối tượng bọc (wrapper objects).
- Nếu chỉ gán giá trị thuần túy `row.field.value = "newValue"`, giá trị này **chỉ tồn tại trên biến tạm của Lua**, hoàn toàn chưa được ghi vào bộ nhớ C++ của game!
- Trong tài liệu `DOC.MD` của Live Editor, để giá trị thực sự được ghi đè (commit) vào RAM game, bắt buộc phải gọi hàm C++:
  ```lua
  local success = EditDBTableField(row["fieldname"])
  assert(success, "Commit to RAM failed!")
  ```
- Đây chính là lý do vì sao ở các lần sửa trước đó người dùng có cảm giác "chưa được lưu": dữ liệu mới chỉ đổi ở tầng Lua mà chưa đồng bộ vào tầng RAM C++.

---

## 3. NGUYÊN NHÂN GỐC RỄ (ROOT CAUSES) & CƠ CHẾ GÂY CRASH

Thông qua việc phân tích toàn bộ 62 file dữ liệu khóa ngoại và đối chiếu với file minidump thực tế trên máy người dùng, chúng tôi đã xác định chính xác **5 nguyên nhân cốt lõi**:

### Nguyên nhân 1: Xung đột Khóa Ngoại giữa CLB và ĐTQG trong bảng `teamplayerlinks`
- Trong cơ chế của FIFA/FC, mỗi cầu thủ thi đấu cho cả CLB và Đội tuyển Quốc gia sẽ có **2 dòng riêng biệt** trong bảng `teamplayerlinks`:
  * **Dòng liên kết CLB:** Khóa `artificialkey` nằm trong dải `566 - 594` (trỏ về CLB Bình Tân FC `115486`).
  * **Dòng liên kết ĐTQG:** Khóa `artificialkey` nằm trong dải `16824 - 16849` (trỏ về ĐTQG Việt Nam `111527`).
- **Lỗi phát sinh:** Khi script gom quân chạy trước đó, lệnh duyệt gán `teamid = 115486` cho mọi dòng có `playerid` từ 900 đến 928 đã vô tình biến cả 2 dòng của mỗi cầu thủ thành 2 hợp đồng CLB Bình Tân FC!
- **Hậu quả:** Bình Tân FC bị gán 2 bản thể cho cùng 1 người, còn ĐTQG Việt Nam bị tụt xuống còn **0 cầu thủ**.

### Nguyên nhân 2: Trùng lặp nghiêm trọng trong Sơ đồ chiến thuật `cm_teamsheets`
- Khi người dùng ở trong Career Mode, game không đọc bảng sơ đồ mặc định `default_teamsheets` mà đọc bảng riêng của Career Mode là **`cm_teamsheets`**.
- Tại dòng của Bình Tân FC (`teamid = 115486`):
  * Từ `playerid11` đến `playerid27`: Danh sách cầu thủ đăng ký hợp lệ.
  * Từ `playerid28` đến `playerid47`: **Lặp lại nguyên xi toàn bộ danh sách trên lần thứ 2!**
  * Đặc biệt xuất hiện các cặp trùng liền kề: Slot 30 & 31 cùng mang ID `916` (Xuân Trường), Slot 44 & 45 cùng mang ID `922` (Hendrio).
- **Cơ chế Crash:** Khi người dùng bấm vào Quản lý đội hình, Engine UI của Frostbite cố gắng khởi tạo cùng lúc 2 widget thẻ bài cho cùng 1 thực thể cầu thủ $\rightarrow$ Xung đột cây phân cấp giao diện (UI Widget Tree) $\rightarrow$ **Crash lập tức**.

### Nguyên nhân 3: Cầu thủ ảo `freekicktakerid = 1` trong bảng `teams`
- Trong bảng thông tin CLB `teams`, cột người thực hiện đá phạt trực tiếp `freekicktakerid` của Bình Tân FC bị lưu giá trị là `1`.
- Quét toàn bộ 21.830 cầu thủ trong database: **FC 26 hoàn toàn không có cầu thủ nào mang ID = 1**.
- Khi game nạp màn hình phân công vai trò (Roles), nó gọi `GetPlayer(1)` $\rightarrow$ Trả về con trỏ `NULL` $\rightarrow$ Đọc tên/số áo trên con trỏ rỗng $\rightarrow$ Crash.

### Nguyên nhân 4: 10 Cầu thủ chuyển nhượng thiếu hợp đồng trong `career_playercontract`
- Trong số 29 cầu thủ Việt Nam, có 19 cầu thủ ban đầu đã có sẵn hợp đồng thi đấu.
- **10 cầu thủ còn lại** *(gồm: Đình Bắc 923, Công Phượng 909, Hồ Tấn Tài 902, Khuất Văn Khang 924, Bùi Tấn Trường 919, Phí Minh Long 920, Nguyễn Trọng Đại 904, Nguyễn Văn Vĩ 925, Nguyễn Nhật Minh 926, Đỗ Phi Long 927)* được chuyển nhượng về sau bằng script can thiệp bảng link.
- Do không qua sự kiện đàm phán của game, 10 cầu thủ này **HOÀN TOÀN KHÔNG CÓ BẢN GHI HỢP ĐỒNG** trong bảng `career_playercontract`.

### Nguyên nhân 5: Thiếu bản ghi trong `career_squadranking` và `career_playergrowthuserseason`
- Đây chính là nguyên nhân giải thích vì sao khi xếp Đình Bắc (`923`) đá chính thì **Mô phỏng trận đấu (Simulate Match) bị văng ngay lập tức**:
- Kiểm tra đối chiếu toàn bộ 236 bảng giữa 19 cầu thủ ban đầu và 10 cầu thủ chuyển nhượng thêm:
  * **`career_squadranking` (Bảng thứ bậc đóng góp):** 19 cầu thủ cũ có đủ, 10 cầu thủ mới = **0 bản ghi**!
  * **`career_playergrowthuserseason` (Bảng tính điểm kinh nghiệm sau trận):** 19 cầu thủ cũ có đủ, 10 cầu thủ mới = **0 bản ghi**!
- Khi trận đấu bắt đầu hoặc kết thúc mô phỏng, Match Engine duyệt qua 11 cầu thủ đá chính để cộng điểm phát triển và cập nhật phong độ. Khi gặp Đình Bắc (`923`), hàm truy xuất trả về con trỏ `NULL (0x00000000)`.

---

## 4. BẰNG CHỨNG XÁC THỰC TỪ PHÂN TÍCH NHỊ PHÂN FILE CRASH DUMP (.MDMP)

Chúng tôi đã cài đặt parser chuyên dụng `minidump` và trích xuất trực tiếp file dump sinh ra trên máy người dùng tại:
```text
C:\Users\Thien\AppData\Local\EA SPORTS FC 26\CrashDumps\CrashDump_2026.10.11_20.34.48.552.mdmp
```

### 4.1. Thông số ngoại lệ (Exception Record):
- **Mã lỗi:** `EXCEPTION_ACCESS_VIOLATION (0xc0000005)`
- **Địa chỉ xảy ra lỗi:** `0x1485673ed` (Bên trong module `D:\EA\EA SPORTS FC 26\FC26.exe`, Crash RVA: `0x85673ed`)
- **Tham số ngoại lệ:**
  * `ExceptionInformation[0] = 0x0` $\rightarrow$ Thao tác cố gắng thực hiện: **ĐỌC BỘ NHỚ (READ)**
  * `ExceptionInformation[1] = 0x0000000000000004` $\rightarrow$ Địa chỉ bộ nhớ bị vi phạm: **`0x4`**

### 4.2. Giải mã ý nghĩa địa chỉ `0x4`:
Trong kiến trúc máy tính x64, địa chỉ `0x4` là bằng chứng không thể chối cãi của việc:
- Game gọi một hàm tìm kiếm đối tượng (ví dụ: `GetPlayerContract(923)` hoặc `GetSquadRanking(923)`).
- Hàm tìm kiếm không thấy bản ghi trong bảng nên trả về con trỏ rỗng: `ptr = 0x0000000000000000 (NULL)`.
- Đoạn mã máy C++ ngay sau đó cố gắng đọc một thuộc tính nằm ở vị trí lệch 4 byte (offset `+0x4` - ví dụ trường `wage` hoặc `status`):
  ```assembly
  mov eax, dword ptr [rcx + 4]   ; rcx đang là 0x0 -> Cố đọc bộ nhớ tại 0x0 + 4 = 0x4!
  ```
- Hệ điều hành Windows chặn lại lập tức và phát sinh lỗi `EXCEPTION_ACCESS_VIOLATION`, làm game sập về desktop.

### 4.3. Bảng Call Stack trích xuất từ Minidump:
Call stack ghi nhận chuỗi hàm của FC26.exe đang xử lý luồng trận đấu trước khi sập:
- `FC26.exe + 0x85673ed` (Điểm sập - Crash Site)
- `FC26.exe + 0x56c7ae9` (Hàm xử lý cập nhật trạng thái cầu thủ)
- `FC26.exe + 0x85b08f6`
- `FC26.exe + 0x208c9bd`
- `FC26.exe + 0x7465591` (Hàm Match Flow Controller)

---

## 5. BẢN CHẤT LỊCH SỬ CHUYỂN NHƯỢNG TRONG GAME

Từ các hình ảnh chụp màn hình do người dùng cung cấp từ tab *Lịch sử chuyển nhượng* của Career Mode:
1. **Các vụ chuyển nhượng đến chính quy:**
   - Ngày 26/07: Nguyễn Đình Bắc (Ký tự do FA $\rightarrow$ BT)
   - Ngày 02/08: Nguyễn Công Phượng (Ký tự do FA $\rightarrow$ BT)
   - Ngày 02/08: Nguyễn Xuân Son (Ký tự do FA $\rightarrow$ BT)
   - Ngày 31/08: Nguyễn Hoàng Đức (Mua từ Young Boys €10M)
   - Ngày 31/08: Đỗ Duy Mạnh (Mua từ CAI €2M)
   - Ngày 31/08: Đoàn Văn Hậu (Mua từ SC Paderborn €4.8M)
   - Ngày 09/08: Nguyễn Văn Vĩ (Mua từ Utrecht €2.3M)
2. **Các vụ chuyển nhượng đi chính quy (Bán & Cho mượn):**
   - Joshua Abiola (`460011`): Cho Wolves mượn
   - Asger Larsen (`460004`): Bán cho Frankfurt (€4.5M)
   - Simon Warren (`460013`): Cho Rayo Vallecano mượn
   - Simon Simon (`460009`): Bán cho Newcastle (€12M)
   - Freddie Perkins (`460000`): Bán cho Monza (€9.7M)
   - Christian Arias (`460021`): Cho Al Ittihad mượn
   - Giacomo Giuliani (`460007`): Bán cho Brighton (€7.7M)
3. **Kết luận kiểm tra:**
   - Bảng cơ sở dữ liệu `previousteam` đã lưu chính xác `previousteamid = 241` (Barcelona) cho toàn bộ 29 cầu thủ.
   - Toàn bộ 7 cầu thủ ngoại bán/cho mượn ở trên **hoàn toàn không có tên** trong sơ đồ thi đấu `cm_teamsheets` hiện tại của Bình Tân FC, loại trừ 100% khả năng xung đột sở hữu CLB từ các cầu thủ ngoại này.

---

## 6. HỆ THỐNG GIẢI PHÁP & CÁC SCRIPT ĐÃ TRIỂN KHAI

Để đưa hệ thống trở lại trạng thái ổn định và dọn dẹp môi trường làm việc gọn gàng, chúng tôi đã thực hiện quy chuẩn hóa:

### 6.1. Dọn dẹp thư mục làm việc (Clean-up)
Đã xóa bỏ toàn bộ 17 file script thử nghiệm trung gian, chuyển nhượng thô và chẩn đoán tạm thời. Hiện tại chỉ lưu giữ các file cốt lõi:
- **Thư mục `lua/` trong repository:**
  * `viet_hoa_auto_01.lua` đến `viet_hoa_auto_09.lua`: Bộ mã nguồn Việt hóa chính thức (autorun).
  * `buff_vietnam_squad.lua`: Script tăng cường chỉ số cầu thủ Việt Nam chuẩn C1.
  * `dump_all_tables_and_fk_analysis.lua`: Công cụ phân tích và trích xuất 236 bảng Database.
  * `fix_database_permanently.lua`: Master script sửa triệt để lỗi trùng lặp sơ đồ và khóa ngoại.
- **Thư mục `C:\FC 26 Live Editor\lua\`:**
  * Giữ lại 2 công cụ quan trọng nhất: `dump_all_tables_and_fk_analysis.lua` và `fix_database_permanently.lua`.

### 6.2. Master Script sửa triệt để Database: `fix_database_permanently.lua`
Script này sử dụng trực tiếp hàm C++ `EditDBTableField(field)` để ép ghi thẳng dữ liệu sạch vào RAM:
1. **Dọn sạch `cm_teamsheets` & `default_teamsheets`:**
   - Quét qua 52 slot cầu thủ (`playerid0` đến `playerid51`).
   - Giữ lại đúng bản thể đầu tiên hợp lệ của mỗi cầu thủ.
   - Toàn bộ các slot nhân đôi từ slot 28 trở đi được gán về `-1` và commit vào RAM.
2. **Khôi phục Đội tuyển Quốc gia Việt Nam:**
   - Trả 26 dòng ở dải khóa `16824 - 16849` trong bảng `teamplayerlinks` về đúng `teamid = 111527`.
   - Giữ nguyên duy nhất 1 liên kết CLB cho Bình Tân FC (`566 - 594`).
3. **Sửa vai trò đá phạt:**
   - Đưa `freekicktakerid = 1` trong bảng `teams` về `-1` (hủy ID rác không tồn tại).

### 6.3. Script bổ sung Hợp đồng & Tăng trưởng: `fix_career_growth_and_ranking.lua`
Script này sử dụng hàm C++ `InsertDBTableRow(table, data)`:
1. Tạo đầy đủ bản ghi hợp đồng trong `career_playercontract` cho cả 10 cầu thủ còn thiếu (thời hạn 24 tháng, lương 5.000$).
2. Tạo đầy đủ bản ghi thứ bậc đội hình trong `career_squadranking` với điểm overall rating chuẩn.
3. Đọc 35 chỉ số gốc từ bảng `players` và nạp vào bảng `career_playergrowthuserseason` để loại bỏ hoàn toàn con trỏ NULL khi tính điểm sau trận.

---

## 7. QUY TRÌNH VẬN HÀNH CHUẨN ĐỂ KHÔNG BỊ MẤT DỮ LIỆU

Mỗi khi can thiệp vào Database của Career Mode qua Live Editor, người dùng cần tuân thủ nghiêm ngặt quy trình 3 bước sau:

```
┌────────────────────────┐     ┌────────────────────────┐     ┌────────────────────────┐
│  Bước 1: Chạy Script   │ ──> │ Bước 2: Kiểm tra Game  │ ──> │   Bước 3: SAVE GAME    │
│  (Thực thi qua Lua     │     │ (Vào menu Quản lý      │     │ (Lưu game ngay tại     │
│   Engine Live Editor)  │     │  đội hình kiểm tra)    │     │  Menu chính Career)    │
└────────────────────────┘     └────────────────────────┘     └────────────────────────┘
```

> **LƯU Ý CỰC KỲ QUAN TRỌNG VỀ LƯU GAME (SAVE GAME):**  
> Khi một script Lua can thiệp vào RAM game, dữ liệu mới **chỉ nằm tạm thời trên bộ nhớ RAM**.  
> Nếu bạn chưa Save Game mà vội bấm vào trận hoặc tắt game, toàn bộ dữ liệu sửa đổi trong RAM sẽ biến mất, và lần sau mở game lên nó sẽ đọc lại file save cũ trên ổ cứng $\rightarrow$ Lỗi cũ sẽ tái xuất hiện.  
> Do đó, **bắt buộc phải thực hiện thao tác LƯU GAME (Save Game Career Mode)** ngay sau khi chạy script thành công để game ghi đè dữ liệu chuẩn hóa xuống file `.CM` trên ổ cứng vĩnh viễn!
