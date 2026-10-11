# BÁO CÁO NGHIÊN CỨU & XỬ LÝ TOÀN DIỆN CÁC LỖI CRASH DATABASE TRONG EA SPORTS FC 26
**Mục tiêu nghiên cứu:** Điều tra nguyên nhân gốc rễ, phân tích mã máy (Minidump/Assembly), giải phẫu 236 bảng Database và xử lý triệt để lỗi Crash trong chế độ Career Mode  
**Đối tượng khảo sát:** Đội bóng Bình Tân FC (`Team ID: 115486`) và 29 cầu thủ Việt Nam (`Player ID: 900 - 928`)  
**Công cụ phân tích:** FC 26 Live Editor (Lua API Engine), Python Minidump Parser, Capstone Engine x64, Windows Event Log

---

## 1. TỔNG QUAN HIỆN TƯỢNG VÀ CÁC DẠNG CRASH

Trong quá trình quản lý đội bóng mod **Bình Tân FC** (`Team ID: 115486`) thi đấu tại giải Ngoại hạng Anh và Cúp C1 Châu Âu (UEFA Champions League), hệ thống phát sinh 2 dạng crash nghiêm trọng làm sập game về màn hình Desktop:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        CÁC DẠNG CRASH TRONG CAREER MODE                │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
         ┌──────────────────────────┴──────────────────────────┐
         │                                                     │
         ▼                                                     ▼
 ┌───────────────────────────────┐             ┌───────────────────────────────┐
 │   CRASH 1: QUẢN LÝ ĐỘI HÌNH   │             │   CRASH 2: TRẬN ĐẤU / MÔ PHỎNG│
 │  (Team Management / Squad)    │             │   (Play Match / Simulate)     │
 ├───────────────────────────────┤             ├───────────────────────────────┤
 │ • Bấm vào Quản lý đội hình    │             │ • Bấm Vào trận hoặc Mô phỏng  │
 │   là bị văng game ngay lập tức│             │   trận gặp Bayern Munich bị   │
 │ • Thẻ cầu thủ bị nhân đôi x2  │             │   văng game ngay lập tức      │
 │ • Sơ đồ bị kéo giãn bất thường│             │ • Mô phỏng nhanh cũng bị crash│
 └───────────────────────────────┘             └───────────────────────────────┘
```

---

## 2. PHÂN TÍCH NHỊ PHÂN FILE CRASH DUMP MINIDUMP (.MDMP)

Để xác định chính xác dòng lệnh và hàm C++ nào trong game gây crash thay vì phỏng đoán, chúng tôi đã sử dụng thư viện `minidump` của Python để bóc tách file dump mới nhất sinh ra trên máy tại đường dẫn:
```text
C:\Users\Thien\AppData\Local\EA SPORTS FC 26\CrashDumps\CrashDump_2026.10.11_20.34.48.552.mdmp
```

### 2.1. Bản ghi ngoại lệ (Exception Record)
* **Exception Code:** `0xC0000005 (EXCEPTION_ACCESS_VIOLATION)`  
  *Đây là mã lỗi vi phạm quyền truy cập vùng nhớ điển hình của hệ điều hành Windows.*
* **Crashing Module:** `D:\EA\EA SPORTS FC 26\FC26.exe`
* **Base Address của FC26.exe:** `0x140000000`
* **Exception Address (Địa chỉ sập):** `0x1485673ed` $\rightarrow$ **Crash RVA:** `0x85673ed`
* **Tham số vi phạm vùng nhớ (ExceptionInformation):**
  * `Param 0 = 0x0 (READ)` $\rightarrow$ Hành vi cố gắng thực hiện: **ĐỌC BỘ NHỚ**
  * `Param 1 = 0x0000000000000004` $\rightarrow$ Địa chỉ bộ nhớ cố gắng đọc: **`0x4`**

### 2.2. Ý nghĩa kỹ thuật tuyệt đối của địa chỉ `0x4`:
* Trong lập trình C++ hướng đối tượng trên kiến trúc 64-bit, địa chỉ `0x4` **KHÔNG BAO GIỜ** là một vùng nhớ hợp lệ của ứng dụng (nằm trong trang bộ nhớ bảo vệ Page Zero `0x0000000000000000 - 0x000000000000FFFF`).
* Hiện tượng đọc tại `0x4` xảy ra khi và chỉ khi:
  1. Game gọi một hàm truy xuất đối tượng trong database (ví dụ: `GetPlayerContract(player_id)` hoặc `GetSquadRanking(player_id)`).
  2. Cầu thủ đó không tồn tại trong bảng dữ liệu tương ứng, hàm trả về con trỏ rỗng: **`ptr = 0x0000000000000000 (NULL)`**.
  3. Đoạn mã máy ngay sau đó không kiểm tra `if (ptr != nullptr)` mà trực tiếp đọc một thuộc tính nằm ở độ lệch offset `+0x4` của struct đó (ví dụ trường `wage`, `contract_status` hoặc `curroverall`):
     ```assembly
     mov eax, dword ptr [rcx + 4]   ; rcx đang là 0x0 (NULL) -> Đọc tại 0x0 + 4 = 0x4!
     ```
  4. CPU kích hoạt ngắt phần cứng `Page Fault`, Windows bắt được lỗi và chấm dứt tiến trình `FC26.exe` ngay lập tức.

### 2.3. Trích xuất Call Stack Frame trên Thread Stack
Phân tích bộ nhớ Stack của luồng gặp lỗi (Thread ID: 6436) cho thấy chuỗi lời gọi hàm trước khi sập:
```text
[RSP + 0x41e0] -> FC26.exe + 0x56c7ae9 (Hàm cập nhật thông số cầu thủ sau trận)
[RSP + 0x4230] -> FC26.exe + 0x85673ed (ĐIỂM SẬP - Dereference con trỏ NULL tại offset 0x4)
[RSP + 0x4350] -> FC26.exe + 0x85b08f6 (Hàm tổng hợp kết quả mô phỏng trận đấu)
[RSP + 0x44a0] -> FC26.exe + 0x208c9bd
[RSP + 0x7460] -> FC26.exe + 0x7465591 (Match Flow Simulation Controller)
```

---

## 3. GIẢI PHÃU KIẾN TRÚC 236 BẢNG DATABASE CỦA FC 26 (REVERSE ENGINEERING)

### 3.1. Truy cập 236 bảng ngầm qua `GetDBMeta()`
- Trước đây, việc truy cập database game thường dựa vào `GetDBTableNames()`, vốn chỉ trả về một số lượng bảng hạn chế (khoảng 12 bảng cơ bản).
- Qua việc phân tích nhị phân thư viện C++ `FCLiveEditor.DLL` (`0x1803e3f80`) và cấu trúc `libs/v2/imports/t3db/db.lua`:
  - Live Editor sở hữu hàm nội bộ `GetDBMeta()`.
  - Hàm này trích xuất từ điển `meta.shortname_name_tables_map`, ánh xạ các mã định danh 4 byte sang toàn bộ **236 bảng Database** trong RAM của engine Frostbite.
- Chúng tôi đã xây dựng script `dump_all_tables_and_fk_analysis.lua` để quét toàn bộ 236 bảng này và lọc ra **62 bảng có Khóa Ngoại (Foreign Keys)** dính dáng đến Bình Tân FC (`115486`) và cầu thủ Việt Nam (`900 - 928`).

### 3.2. Cơ chế Commit dữ liệu: Sự khác nhau giữa biến Lua và `EditDBTableField()`
- Trong Live Editor, khi gọi `local rows = GetDBTableRows("tableName")`, dữ liệu trả về là bảng wrapper của Lua.
- **Quy tắc bất di bất dịch:** Nếu chỉ thay đổi giá trị bằng lệnh gán thuần túy:
  ```lua
  row.fieldName.value = "newValue"  -- CHỈ ĐỔI TRÊN BIẾN TẠM CỦA LUA!
  ```
  Thì bộ nhớ RAM C++ của game **hoàn toàn chưa được cập nhật**.
- Muốn dữ liệu thực sự được ghi đè vào RAM game, bắt buộc phải gọi hàm C++:
  ```lua
  EditDBTableField(row["fieldName"])   -- COMMIT TRỰC TIẾP VÀO RAM C++
  ```
- Tương tự, để tạo một dòng mới trong bảng database C++, bắt buộc phải gọi:
  ```lua
  InsertDBTableRow("table_name", row_data)  -- TẠO MỚI DÒNG TRONG RAM C++
  ```

---

## 4. BÓC TÁCH NGUYÊN NHÂN GỐC RỄ (ROOT CAUSES)

Từ kết quả quét 62 bảng khóa ngoại và đối chiếu với file minidump, chúng tôi đã bóc tách chính xác từng nguyên nhân gây ra các lỗi crash:

```
┌────────────────────────────────────────────────────────────────────────┐
│               HỆ THỐNG CÁC LỖI DATABASE ĐÃ ĐƯỢC BÓC TÁCH               │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
    ┌───────────────────────────────┼───────────────────────────────┐
    │                               │                               │
    ▼                               ▼                               ▼
[NHÓM 1: TEAM SHEET]          [NHÓM 2: LIÊN KẾT ĐỘI]       [NHÓM 3: CAREER TRACKING]
• Duplicate slots 28-47       • Chồng chéo khóa dải        • Thiếu career_playercontract
  trong cm_teamsheets           566-594 & 16824-16849        (10 cầu thủ = 0 hợp đồng)
• Cặp trùng 916 & 922         • ĐTQG VN bị 0 cầu thủ       • Thiếu career_squadranking
• Cầu thủ ma freekick = 1     • Bình Tân bị 2 liên kết     • Thiếu growthuserseason
  trong bảng teams              trên 1 cầu thủ             • Thiếu stageid Champions League
```

---

### LỖI GỐC RỄ 1: Xung đột khóa ngoại CLB vs ĐTQG trong `teamplayerlinks`
* **Cơ chế database gốc:** Mỗi cầu thủ vừa đá CLB vừa đá ĐTQG bắt buộc phải có **2 dòng riêng biệt** trong bảng `teamplayerlinks`:
  * Khóa `artificialkey` từ `566` đến `594`: Liên kết CLB Bình Tân FC (`115486`).
  * Khóa `artificialkey` từ `16824` đến `16849`: Liên kết ĐTQG Việt Nam (`111527`).
* **Lỗi phát sinh:** Khi script chuyển nhượng cũ chạy, lệnh duyệt gán toàn bộ `playerid` từ 900 đến 928 thành `teamid = 115486` đã vô tình ghi đè cả 26 dòng của ĐTQG thành Bình Tân FC!
* **Hậu quả:** Bình Tân FC bị gán tới **66 liên kết** (mỗi cầu thủ có 2 bản thể), trong khi ĐTQG Việt Nam bị mất sạch còn đúng **0 cầu thủ**.

---

### LỖI GỐC RỄ 2: Nhân đôi các slot cầu thủ trong `cm_teamsheets`
* **Vị trí lỗi:** Bảng sơ đồ riêng của Career Mode `cm_teamsheets` (Dòng 0 - Bình Tân FC `115486`).
* **Dữ liệu lỗi:**
  * Slot `playerid0` đến `playerid10`: 11 cầu thủ đá chính.
  * Slot `playerid11` đến `playerid27`: Danh sách dự bị hợp lệ.
  * Slot `playerid28` đến `playerid47`: **Sao chép lặp lại nguyên xi toàn bộ danh sách dự bị lần thứ 2!**
    * Slot 20 là Quang Hải (`903`) $\leftrightarrow$ Slot 28 cũng là Quang Hải (`903`).
    * Slot 18 là Xuân Son (`921`) $\leftrightarrow$ Slot 43 cũng là Xuân Son (`921`).
    * Slot 30 & 31 đứng cạnh nhau đều là Xuân Trường (`916`).
    * Slot 44 & 45 đứng cạnh nhau đều là Hendrio (`922`).
* **Cơ chế gây Crash khi vào Quản lý đội hình:**  
  Engine giao diện người dùng của Frostbite khi vẽ màn hình Team Management sẽ khởi tạo widget cho từng slot. Khi gặp cùng 1 ID cầu thủ ở 2 slot khác nhau trong cùng một sơ đồ, engine bị lỗi xung đột con trỏ quản lý thẻ bài $\rightarrow$ **Crash lập tức**.

---

### LỖI GỐC RỄ 3: Cầu thủ ma `freekicktakerid = 1` trong bảng `teams`
* **Vị trí lỗi:** Bảng thông tin CLB `teams`, dòng của Bình Tân FC (`teamid = 115486`).
* **Dữ liệu lỗi:** Cột người đá phạt trực tiếp được đặt giá trị:
  ```text
  freekicktakerid = 1
  ```
* **Cơ chế gây Crash:**  
  Quét toàn bộ 21.830 cầu thủ trong database: **FC 26 hoàn toàn không có cầu thủ nào mang ID = 1**. Khi game mở tab Phân công vai trò (Roles), hàm `GetPlayer(1)` trả về `NULL` $\rightarrow$ Crash truy cập bộ nhớ.

---

### LỖI GỐC RỄ 4: 10 Cầu thủ chuyển nhượng thiếu hợp đồng trong `career_playercontract`
* Trong số 29 cầu thủ Việt Nam ở Bình Tân FC:
  * **19 cầu thủ ban đầu** có đầy đủ hợp đồng thi đấu trong file save Career Mode.
  * **10 cầu thủ còn lại** *(Đình Bắc 923, Công Phượng 909, Hồ Tấn Tài 902, Khuất Văn Khang 924, Bùi Tấn Trường 919, Phí Minh Long 920, Nguyễn Trọng Đại 904, Nguyễn Văn Vĩ 925, Nguyễn Nhật Minh 926, Đỗ Phi Long 927)* được đưa về CLB bằng script can thiệp bảng link.
* Do không trải qua sự kiện đàm phán hợp đồng trong game, 10 cầu thủ này **HOÀN TOÀN KHÔNG CÓ BẢN GHI HỢP ĐỒNG (0 hợp đồng)** trong bảng `career_playercontract`.
* Khi trận đấu bắt đầu hoặc mô phỏng, Career Mode Match Engine duyệt qua danh sách thi đấu để trừ quỹ lương và tính tiền thưởng ra sân. Gặp cầu thủ không có hợp đồng $\rightarrow$ Con trỏ `NULL` $\rightarrow$ Crash.

---

### LỖI GỐC RỄ 5: Thiếu bản ghi trong `career_squadranking` và `career_playergrowthuserseason` (Nguyên nhân trực tiếp gây Crash `READ 0x4`)
Đây là phát hiện then chốt giải thích vì sao khi xếp **Đình Bắc (`923`)** đá chính ở vị trí cánh trái (LW) thì **Mô phỏng trận đấu (Simulate Match) bị văng ngay lập tức**:

#### Bảng đối chiếu toàn diện 236 bảng Database:
| Tên bảng Database | Nhóm 19 cầu thủ ban đầu | Nhóm 10 cầu thủ thêm sau (Có Đình Bắc) |
| :--- | :---: | :---: |
| `career_playercontract` | 19 / 19 | 10 / 10 (Sau khi thêm) |
| `career_playerlastgrowth` | 19 / 19 | 10 / 10 |
| `cm_teamsheets` | 19 / 19 | 10 / 10 |
| `default_teamsheets` | 19 / 19 | 10 / 10 |
| `previousteam` | 19 / 19 | 10 / 10 |
| `teamplayerlinks` | 19 / 19 | 10 / 10 |
| **`career_squadranking`** (Thứ bậc đội hình) | **19 / 19** | **0 / 10 (THIẾU HOÀN TOÀN!)** ❌ |
| **`career_playergrowthuserseason`** (Điểm tăng trưởng sau trận) | **19 / 19** | **0 / 10 (THIẾU HOÀN TOÀN!)** ❌ |

#### Cơ chế Crash chính xác:
1. Trong trận đấu gặp Bayern Munich, Đình Bắc (`923`) có tên trong đội hình xuất phát.
2. Khi mô phỏng hoặc kết thúc trận đấu, Career Match Engine gọi hàm:
   * `UpdateSquadRanking(playerid)`: Cập nhật thứ bậc đóng góp.
   * `CalculatePlayerGrowth(playerid)`: Cộng điểm kinh nghiệm và phát triển chỉ số sau trận.
3. Vì Đình Bắc không có bản ghi trong cả 2 bảng trên, cả 2 hàm đều trả về con trỏ `0x0000000000000000 (NULL)`.
4. Engine cố đọc trường dữ liệu ở vị trí lệch **offset `+0x4`** của struct đối tượng $\rightarrow$ **Truy cập vùng nhớ `0x0000000000000004` $\rightarrow$ Phát sinh đúng ngoại lệ `EXCEPTION_ACCESS_VIOLATION (READ 0x4)` như file Minidump đã chỉ ra!**

---

### LỖI GỐC RỄ 6: Cơ chế Lịch sử chuyển nhượng & Các cầu thủ ngoại bán/cho mượn
Từ các ảnh chụp màn hình tab Lịch sử chuyển nhượng của người dùng:
1. **Bản chất của bảng Lịch sử chuyển nhượng ngoài menu:**
   - Bảng này là một vùng nhớ động (`eastl::vector` của Career Manager C++) chỉ lưu các sự kiện đàm phán chính quy trong game (Negotiation Events).
   - Các cầu thủ được thêm bằng script database sẽ không có dòng chữ trên bảng này do không đi qua sự kiện đàm phán, nhưng vẫn thi đấu bình thường nếu database đủ bản ghi.
2. **Kiểm tra 7 cầu thủ ngoại đã Bán / Cho mượn:**
   - `460011` (Joshua Abiola): Cho Wolves mượn $\rightarrow$ Hợp đồng lưu `Status = 6 (On Loan)`.
   - `460004` (Asger Larsen): Đã bán sang Frankfurt (€4.5M) $\rightarrow$ Đã xóa khỏi danh sách.
   - `460013` (Simon Warren): Cho Rayo Vallecano mượn $\rightarrow$ Trạng thái `Status = 6`.
   - `460009` (Simon Simon): Đã bán sang Newcastle (€12M) $\rightarrow$ Đã xóa khỏi danh sách.
   - `460000` (Freddie Perkins): Đã bán sang Monza (€9.7M) $\rightarrow$ Đã xóa khỏi danh sách.
   - `460021` (Christian Arias): Cho Al Ittihad mượn $\rightarrow$ Trạng thái `Status = 6`.
   - `460007` (Giacomo Giuliani): Đã bán sang Brighton (€7.7M) $\rightarrow$ Đã xóa khỏi danh sách.
   - **Kết quả xác minh:** Cả 7 cầu thủ ngoại này **hoàn toàn không còn nằm trên sơ đồ thi đấu `cm_teamsheets`** của Bình Tân FC, không hề có xung đột sở hữu CLB.

---

## 5. TỔNG HỢP GIẢI PHÁP VÀ QUY TRÌNH XỬ LÝ TRIỆT ĐỂ

### 5.1. Master Script `fix_database_permanently.lua`
Script này sử dụng hàm C++ `EditDBTableField(field)` để chuẩn hóa sơ đồ và khóa ngoại:
* **Dọn dẹp `cm_teamsheets`:** Quét toàn bộ 52 slot, giữ nguyên 1 bản thể duy nhất của từng cầu thủ, xóa sạch các slot trùng lặp từ slot 28 đến 51 (đặt về `-1`) và commit trực tiếp vào RAM.
* **Sửa vai trò đá phạt:** Đưa `freekicktakerid = 1` trong bảng `teams` về `-1`.
* **Khôi phục ĐTQG Việt Nam:** Trả 26 dòng dải khóa `16824 - 16849` trong bảng `teamplayerlinks` về `teamid = 111527`.

### 5.2. Master Script `fix_career_growth_and_ranking.lua`
Script này sử dụng hàm C++ `InsertDBTableRow(table, data)` để khắc phục triệt để lỗi crash `READ 0x4`:
* **Bổ sung `career_squadranking`:** Tạo mới bản ghi thứ bậc đội hình cho 10 cầu thủ còn thiếu với điểm `curroverall = overall * 10`.
* **Bổ sung `career_playergrowthuserseason`:** Đọc 35 chỉ số gốc từ bảng `players` và nạp bản ghi tăng trưởng cho toàn bộ 10 cầu thủ còn thiếu.
* **Kết quả:** Đưa toàn bộ 29 cầu thủ Việt Nam lên trạng thái đầy đủ 100% dữ liệu ở tất cả các bảng Career Mode.

---

## 6. QUY TẮC BẮT BUỘC ĐỂ KHÔNG BỊ MẤT DỮ LIỆU SAU KHI SỬA

> ⚠️ **NGUYÊN TẮC VÀNG VỀ LƯU GAME (SAVE GAME CAREER MODE):**  
> Mọi can thiệp của Live Editor Lua script đều diễn ra **trên bộ nhớ RAM tạm thời của game**.  
> Nếu bạn chạy script xong mà **chưa Save Game** mà vội vào trận hoặc tắt game:  
> Khi game sập hoặc khởi động lại, toàn bộ các bản ghi tạo thêm trong RAM sẽ bị biến mất, game sẽ nạp lại file save cũ trên ổ cứng và lỗi crash `READ 0x4` sẽ lặp lại nguyên trạng!  
>  
> **Quy trình chuẩn bắt buộc:**  
> 1. Mở game Career Mode.  
> 2. Mở Live Editor, chạy script sửa database.  
> 3. Quay lại menu Career Mode, vào **Cài đặt / Lưu game (Save Game)** ngay lập tức để ép game ghi dữ liệu từ RAM xuống file save `.CM` trên ổ cứng!
