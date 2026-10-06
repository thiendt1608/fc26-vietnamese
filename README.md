# EA SPORTS FC 26 - Vietnamese Localization Pipeline

Dự án tự động hóa quy trình Việt hóa chất lượng cao cho EA SPORTS FC 26, can thiệp trực tiếp vào bộ nhớ game thông qua FC 26 Live Editor Lua autorun script (`SetGameLocString`).

## 1. Tổng quan giải pháp

Khi mod ngôn ngữ cho EA SPORTS FC qua phương thức truyền thống đóng gói `.fifamod` bằng FIFA Editor Tool (FET), quá trình nén lại file cơ sở dữ liệu chuỗi `eng_us.db` thường gây lỗi mã hóa UTF-8 đa byte (các ký tự tiếng Việt có dấu như `ơ`, `ư`, `ắ`, `ẵ`... bị lỗi hiển thị thành ô vuông).

Giải pháp trong dự án này:
- Can thiệp ở cấp độ RAM khi game khởi chạy bằng cách nạp các file script Lua trong thư mục autorun của FC 26 Live Editor (`C:\FC 26 Live Editor\lua\autorun\`).
- Gọi hàm API `SetGameLocString(stringid, text)` để ghi đè chuỗi ngôn ngữ gốc bằng tiếng Việt chuẩn.
- Toàn bộ chuỗi nguồn được trích xuất trực tiếp từ bản phát hành gốc của game (`LanguageStrings1.txt` và `LanguageStrings2.txt` với hơn 103.000 dòng).
- Quy trình dịch thuật được tối ưu hóa với mô hình ngôn ngữ lớn (LLM) qua Gemini Batch API, kết hợp bộ từ điển thuật ngữ bóng đá (Glossary), tài liệu quy chuẩn phong cách và xưng hô (Style Guide), cùng hệ thống kiểm định token nghiêm ngặt.

## 2. Cấu trúc thư mục

```text
fc26-vietnamese/
├── batches/         # Quản lý request, response và trạng thái job của Gemini Batch API
├── data/            # Dữ liệu xử lý, từ điển thuật ngữ, style guide và kết quả dịch
│   ├── glossary.json               # Quy định các từ khóa giữ nguyên hoặc dịch chuẩn
│   ├── style_guide.md              # Quy chuẩn xưng hô, văn phong theo từng ngữ cảnh
│   ├── keep_ids.txt                # Danh sách các ID giữ nguyên gốc tiếng Anh
│   ├── units.jsonl                 # Tập dữ liệu sau khi dedup và bảo vệ token
│   ├── translations.jsonl          # Kết quả dịch tổng hợp (nguồn chân lý)
│   └── pilot_*                     # Dữ liệu thử nghiệm và so sánh chất lượng model
├── input/           # Dữ liệu chuỗi nguồn trích xuất từ game gốc
│   ├── LanguageStrings1.txt        # File chuỗi 1 (65.535 dòng dữ liệu)
│   └── LanguageStrings2.txt        # File chuỗi 2 (37.715 dòng dữ liệu)
├── lua/             # File Lua script thành phẩm nạp vào Live Editor
│   └── viet_hoa_auto_01.lua .. 09.lua  # Phân trang ~10.000 chuỗi / file
├── src/             # Mã nguồn pipeline xử lý
│   ├── common.py                   # Tiện ích chung, regex bảo vệ token, xử lý escape
│   ├── parse.py                    # Kiểm tra tính toàn vẹn và cấu trúc dữ liệu nguồn
│   ├── prepare.py                  # Lọc quy tắc KEEP, gom cụm dedup, bọc token
│   ├── translate.py                # Schema, prompt, validation và chạy thử nghiệm
│   ├── batch.py                    # Điều phối Gemini Batch API (build, submit, fetch)
│   └── build_lua.py                # Sinh file Lua và kiểm tra tính hợp lệ bằng lupa
├── .env.example     # File mẫu cấu hình biến môi trường
└── .gitignore       # Danh sách loại trừ cho Git
```

## 3. Quy trình thực hiện (Pipeline Workflow)

### Bước 1: Phân tích và kiểm tra dữ liệu nguồn (`src/parse.py`)
- Đọc file TSV nguồn (`LanguageStrings1.txt` và `LanguageStrings2.txt`), kiểm tra tính duy nhất của `stringid` và `hashid`.
- Thống kê các mẫu token điều khiển của game (`^COLOR_...^`, `{C:...}`, `[BR]`, `%s`, `%d`, URL...).

### Bước 2: Chuẩn bị dữ liệu và bảo vệ token (`src/prepare.py`)
- Áp dụng bộ lọc KEEP: Loại bỏ không dịch đối với tên bản quyền, tên giải đấu, tên câu lạc bộ, tên cầu thủ, vị trí thẻ cầu thủ (`GK`, `CB`, `ST`...), URL, các chuỗi chỉ chứa ký tự điều khiển hoặc số.
- Bảo vệ định dạng game: Tạm thời thay thế toàn bộ ký tự đặc biệt, mã màu và placeholder thành định dạng đánh dấu `⟦N⟧` để mô hình không làm biến dạng mã điều khiển.
- Gom cụm trùng lặp (Dedup): Tách nhóm theo tiền tố và ngữ cảnh giới tính (`_MgrM`, `_MgrF`), giảm tổng số dòng cần dịch xuống còn khoảng 70.000 đơn vị (units).
- Xuất kết quả vào `data/units.jsonl` và danh sách ID bỏ qua vào `data/keep_ids.txt`.

### Bước 3: Dịch thuật quy mô lớn với Gemini Batch API (`src/batch.py`)
- Mô hình mặc định: `gemini-3.1-flash-lite` với chế độ cấu hình tư duy `thinking_level = "low"`.
- Tạo các gói request JSONL (`src/batch.py build`) với cấu trúc phân cụm phù hợp hạn ngạch.
- Tải lên và kích hoạt Batch Job (`src/batch.py submit`).
- Theo dõi trạng thái tiến độ (`src/batch.py status`).
- Tải kết quả hoàn thành, chạy bộ kiểm tra tính hợp lệ (kiểm tra token round-trip, định dạng dòng, độ dài, không xuất hiện emoji), sau đó hợp nhất vào `data/translations.jsonl` (`src/batch.py fetch`).

### Bước 4: Tạo file Lua autorun (`src/build_lua.py`)
- Đọc các bản dịch đã hoàn tất từ `data/translations.jsonl`.
- Chuyển đổi các ký tự escape thành chuỗi điều khiển nguyên bản của game.
- Phân chia các cặp ID - Bản dịch thành các tệp Lua độc lập (`viet_hoa_auto_01.lua` đến `09.lua`, mỗi tệp khoảng 10.000 chuỗi) để tối ưu thời gian nạp và dung lượng bộ nhớ.
- Tự động chạy bộ kiểm tra ngoại tuyến bằng thư viện `lupa` (Lua 5.4 runtime) nhằm đảm bảo cú pháp Lua chuẩn 100% trước khi triển khai.

## 4. Hướng dẫn cài đặt và sử dụng

### 4.1. Yêu cầu môi trường
- Python 3.10 trở lên.
- Cài đặt các thư viện Python cần thiết:
  ```bash
  pip install google-genai lupa
  ```

### 4.2. Cấu hình API Key
Tạo file `.env` từ `.env.example` và điền khóa API của Google Gemini:
```env
GEMINI_API_KEY=your_gemini_api_key_here
```

### 4.3. Các lệnh thực thi chính

1. Chuẩn bị dữ liệu:
   ```bash
   python src/prepare.py
   ```

2. Tạo và gửi batch dịch thuật:
   ```bash
   # Tạo file request
   python src/batch.py build --jobs 3

   # Gửi batch lên Gemini API
   python src/batch.py submit

   # Kiểm tra tiến độ
   python src/batch.py status

   # Tải kết quả về và hợp nhất dữ liệu
   python src/batch.py fetch
   ```

3. Xuất file Lua cho game:
   ```bash
   python src/build_lua.py
   ```

### 4.4. Cài đặt vào game FC 26
1. Cài đặt **FC 26 Live Editor**.
2. Sao chép toàn bộ các file `.lua` được tạo ra trong thư mục `lua/` (từ `viet_hoa_auto_01.lua` đến `viet_hoa_auto_09.lua`) vào đường dẫn:
   ```text
   C:\FC 26 Live Editor\lua\autorun\
   ```
3. Khởi động game thông qua bộ khởi chạy mod của Live Editor.
4. Kiểm tra kết quả trong file log tại:
   ```text
   C:\FC 26 Live Editor\viet_hoa_log.txt
   ```

## 5. Lưu ý quan trọng
- Bản mod này chỉ dành cho mục đích sử dụng cá nhân và các chế độ chơi ngoại tuyến (Career Mode, Tournament, Kick Off...).
- Khi tham gia các chế độ chơi trực tuyến có hệ thống chống gian lận (như Ultimate Team trực tuyến hoặc Clubs), vui lòng khởi động game bình thường qua EA App mà không sử dụng Live Editor để đảm bảo an toàn cho tài khoản.
