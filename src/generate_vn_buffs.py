ALT_POS = {901: {'alt1': 25, 'alt2': 12}, 902: {'alt1': 2, 'alt2': 12}, 903: {'alt1': 23, 'alt2': 27}, 905: {'alt1': 5, 'alt2': 8}, 906: {'alt1': 7, 'alt2': 2}, 907: {'alt1': 10, 'alt2': -1}, 908: {'alt1': 18, 'alt2': 10}, 909: {'alt1': 23, 'alt2': 27}, 910: {'alt1': 10, 'alt2': -1}, 911: {'alt1': 10, 'alt2': 3}, 912: {'alt1': 21, 'alt2': -1}, 913: {'alt1': 10, 'alt2': -1}, 915: {'alt1': 10, 'alt2': -1}, 917: {'alt1': 27, 'alt2': 21}, 918: {'alt1': 25, 'alt2': -1}, 921: {'alt1': 21, 'alt2': -1}, 922: {'alt1': 14, 'alt2': 12}, 923: {'alt1': 25, 'alt2': 23}, 924: {'alt1': 27, 'alt2': 14}, 925: {'alt1': 16, 'alt2': 8}, 928: {'alt1': 18, 'alt2': 23}}

"""src/generate_vn_buffs.py
Tao Lua script tu dong buff 29 cau thu Viet Nam len chuan Cup C1 (OVR 79 - 83),
dong thoi chuan hoa chan thuan, sao ky thuat, sao chan khong thuan, the trang va vi tri dung thuc te.
"""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parent.parent

# Danh sach 29 cau thu Viet Nam can buff & chuan hoa thong so
BUFF_DATA = {
    # ------------------ THU MON (GK) ------------------
    900: {
        "name": "Dang Van Lam",
        "pos": 0, "foot": 2, "wf": 3, "sm": 1, "h": 188, "w": 86,  # Chan trai, 1m88, 86kg
        "ovr": 81, "pot": 85,
        "acc": 45, "spd": 46,
        "pos_att": 15, "fin": 15, "pow": 68, "lng_sho": 18, "vol": 16, "pen": 35,
        "vis": 52, "cro": 22, "fk": 25, "sho_pas": 42, "lng_pas": 58, "cur": 24,
        "agi": 62, "bal": 58, "rea": 83, "bal_con": 42, "dri": 25, "com": 78,
        "int": 25, "hea": 32, "def_awa": 22, "std_tac": 20, "sld_tac": 18,
        "jmp": 76, "sta": 65, "str": 82, "agg": 48,
        "gkd": 82, "gkh": 80, "gkk": 78, "gkp": 81, "gkr": 84
    },
    919: {
        "name": "Bui Tan Truong",
        "pos": 0, "foot": 1, "wf": 3, "sm": 1, "h": 188, "w": 84,  # Chan phai, 1m88
        "ovr": 79, "pot": 82,
        "acc": 40, "spd": 40,
        "pos_att": 14, "fin": 12, "pow": 64, "lng_sho": 15, "vol": 14, "pen": 30,
        "vis": 48, "cro": 20, "fk": 22, "sho_pas": 38, "lng_pas": 52, "cur": 20,
        "agi": 56, "bal": 52, "rea": 80, "bal_con": 38, "dri": 22, "com": 76,
        "int": 22, "hea": 28, "def_awa": 20, "std_tac": 18, "sld_tac": 16,
        "jmp": 74, "sta": 60, "str": 80, "agg": 45,
        "gkd": 79, "gkh": 78, "gkk": 75, "gkp": 80, "gkr": 81
    },
    920: {
        "name": "Phi Minh Long",
        "pos": 0, "foot": 1, "wf": 3, "sm": 1, "h": 180, "w": 75,
        "ovr": 78, "pot": 83,
        "acc": 42, "spd": 42,
        "pos_att": 14, "fin": 12, "pow": 60, "lng_sho": 14, "vol": 14, "pen": 28,
        "vis": 46, "cro": 18, "fk": 20, "sho_pas": 36, "lng_pas": 48, "cur": 18,
        "agi": 60, "bal": 56, "rea": 79, "bal_con": 36, "dri": 20, "com": 74,
        "int": 20, "hea": 26, "def_awa": 18, "std_tac": 16, "sld_tac": 15,
        "jmp": 72, "sta": 58, "str": 75, "agg": 42,
        "gkd": 78, "gkh": 77, "gkk": 74, "gkp": 78, "gkr": 80
    },

    # ------------------ HAU VE BIEN (FB / WB) ------------------
    901: {
        "name": "Nguyen Van Toan",
        "pos": 23, "foot": 1, "wf": 3, "sm": 4, "h": 170, "w": 65,  # RW/RM, Sieu toc do
        "ovr": 80, "pot": 85,
        "acc": 92, "spd": 91,
        "pos_att": 82, "fin": 75, "pow": 77, "lng_sho": 74, "vol": 70, "pen": 68,
        "vis": 76, "cro": 77, "fk": 65, "sho_pas": 78, "lng_pas": 68, "cur": 72,
        "agi": 89, "bal": 86, "rea": 82, "bal_con": 82, "dri": 83, "com": 77,
        "int": 38, "hea": 58, "def_awa": 35, "std_tac": 36, "sld_tac": 34,
        "jmp": 74, "sta": 86, "str": 66, "agg": 68,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    902: {
        "name": "Ho Tan Tai",
        "pos": 3, "foot": 1, "wf": 3, "sm": 3, "h": 180, "w": 74,  # RB, len cong ve thu tot
        "ovr": 79, "pot": 83,
        "acc": 82, "spd": 83,
        "pos_att": 74, "fin": 65, "pow": 76, "lng_sho": 68, "vol": 62, "pen": 60,
        "vis": 74, "cro": 81, "fk": 62, "sho_pas": 79, "lng_pas": 74, "cur": 72,
        "agi": 76, "bal": 74, "rea": 80, "bal_con": 78, "dri": 77, "com": 78,
        "int": 80, "hea": 78, "def_awa": 79, "std_tac": 81, "sld_tac": 79,
        "jmp": 80, "sta": 86, "str": 78, "agg": 78,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    905: {
        "name": "Doan Van Hau",
        "pos": 7, "foot": 2, "wf": 3, "sm": 3, "h": 185, "w": 82,  # LB, the hinh ho phap, sut xa manh
        "ovr": 81, "pot": 85,
        "acc": 84, "spd": 85,
        "pos_att": 76, "fin": 68, "pow": 84, "lng_sho": 80, "vol": 68, "pen": 65,
        "vis": 76, "cro": 83, "fk": 74, "sho_pas": 80, "lng_pas": 77, "cur": 78,
        "agi": 75, "bal": 74, "rea": 81, "bal_con": 79, "dri": 78, "com": 80,
        "int": 82, "hea": 83, "def_awa": 81, "std_tac": 83, "sld_tac": 82,
        "jmp": 84, "sta": 87, "str": 86, "agg": 86,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    906: {
        "name": "Vu Van Thanh",
        "pos": 3, "foot": 1, "wf": 4, "sm": 3, "h": 170, "w": 69,  # RB/RWB/LB, the luc doi dao
        "ovr": 79, "pot": 83,
        "acc": 84, "spd": 83,
        "pos_att": 75, "fin": 70, "pow": 80, "lng_sho": 75, "vol": 66, "pen": 72,
        "vis": 74, "cro": 80, "fk": 68, "sho_pas": 79, "lng_pas": 73, "cur": 74,
        "agi": 82, "bal": 80, "rea": 79, "bal_con": 78, "dri": 78, "com": 77,
        "int": 79, "hea": 72, "def_awa": 78, "std_tac": 80, "sld_tac": 79,
        "jmp": 78, "sta": 88, "str": 79, "agg": 80,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    925: {
        "name": "Nguyen Van Vi",
        "pos": 7, "foot": 2, "wf": 3, "sm": 3, "h": 169, "w": 65,  # LB, toc do leo bien
        "ovr": 79, "pot": 82,
        "acc": 88, "spd": 87,
        "pos_att": 72, "fin": 62, "pow": 74, "lng_sho": 68, "vol": 60, "pen": 58,
        "vis": 73, "cro": 80, "fk": 65, "sho_pas": 78, "lng_pas": 72, "cur": 74,
        "agi": 84, "bal": 82, "rea": 78, "bal_con": 77, "dri": 79, "com": 76,
        "int": 78, "hea": 68, "def_awa": 78, "std_tac": 79, "sld_tac": 78,
        "jmp": 76, "sta": 86, "str": 72, "agg": 76,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },

    # ------------------ TRUNG VE (CB) ------------------
    907: {
        "name": "B H Viet Anh",
        "pos": 5, "foot": 1, "wf": 3, "sm": 2, "h": 186, "w": 80,  # CB hien dai, khong chien + tì đè
        "ovr": 81, "pot": 86,
        "acc": 76, "spd": 77,
        "pos_att": 40, "fin": 40, "pow": 72, "lng_sho": 45, "vol": 38, "pen": 55,
        "vis": 65, "cro": 52, "fk": 50, "sho_pas": 76, "lng_pas": 74, "cur": 55,
        "agi": 68, "bal": 66, "rea": 82, "bal_con": 74, "dri": 66, "com": 82,
        "int": 84, "hea": 85, "def_awa": 84, "std_tac": 85, "sld_tac": 83,
        "jmp": 85, "sta": 84, "str": 87, "agg": 84,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    911: {
        "name": "Do Duy Manh",
        "pos": 5, "foot": 1, "wf": 3, "sm": 2, "h": 180, "w": 75,  # CB dap, quyet liet
        "ovr": 80, "pot": 84,
        "acc": 75, "spd": 74,
        "pos_att": 42, "fin": 38, "pow": 75, "lng_sho": 46, "vol": 40, "pen": 58,
        "vis": 66, "cro": 55, "fk": 55, "sho_pas": 76, "lng_pas": 75, "cur": 56,
        "agi": 67, "bal": 65, "rea": 81, "bal_con": 72, "dri": 64, "com": 80,
        "int": 83, "hea": 83, "def_awa": 82, "std_tac": 84, "sld_tac": 83,
        "jmp": 83, "sta": 83, "str": 85, "agg": 88,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    914: {
        "name": "Bui Tien Dung",
        "pos": 5, "foot": 1, "wf": 3, "sm": 2, "h": 176, "w": 72,  # CB thong, boc lot
        "ovr": 79, "pot": 83,
        "acc": 75, "spd": 74,
        "pos_att": 38, "fin": 35, "pow": 68, "lng_sho": 40, "vol": 35, "pen": 52,
        "vis": 64, "cro": 48, "fk": 46, "sho_pas": 75, "lng_pas": 72, "cur": 50,
        "agi": 70, "bal": 69, "rea": 81, "bal_con": 72, "dri": 63, "com": 81,
        "int": 83, "hea": 81, "def_awa": 82, "std_tac": 83, "sld_tac": 82,
        "jmp": 82, "sta": 83, "str": 83, "agg": 82,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    915: {
        "name": "Que Ngoc Hai",
        "pos": 5, "foot": 1, "wf": 3, "sm": 2, "h": 182, "w": 78,  # CB thu linh, chuyen dai cuc hay
        "ovr": 81, "pot": 84,
        "acc": 74, "spd": 75,
        "pos_att": 45, "fin": 42, "pow": 78, "lng_sho": 52, "vol": 45, "pen": 68,
        "vis": 74, "cro": 62, "fk": 65, "sho_pas": 80, "lng_pas": 81, "cur": 65,
        "agi": 66, "bal": 65, "rea": 83, "bal_con": 75, "dri": 67, "com": 85,
        "int": 85, "hea": 84, "def_awa": 85, "std_tac": 85, "sld_tac": 84,
        "jmp": 84, "sta": 84, "str": 86, "agg": 87,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    918: {
        "name": "Nguyen Thanh Chung",
        "pos": 5, "foot": 1, "wf": 3, "sm": 2, "h": 182, "w": 77,  # CB danh dau, tien dao khi can
        "ovr": 79, "pot": 82,
        "acc": 74, "spd": 73,
        "pos_att": 55, "fin": 52, "pow": 76, "lng_sho": 50, "vol": 48, "pen": 58,
        "vis": 62, "cro": 48, "fk": 48, "sho_pas": 74, "lng_pas": 72, "cur": 52,
        "agi": 65, "bal": 64, "rea": 80, "bal_con": 71, "dri": 63, "com": 80,
        "int": 81, "hea": 86, "def_awa": 81, "std_tac": 82, "sld_tac": 80,
        "jmp": 85, "sta": 82, "str": 85, "agg": 83,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    926: {
        "name": "Nguyen Nhat Minh",
        "pos": 5, "foot": 2, "wf": 3, "sm": 2, "h": 180, "w": 75,  # CB tre
        "ovr": 78, "pot": 84,
        "acc": 74, "spd": 75,
        "pos_att": 38, "fin": 32, "pow": 70, "lng_sho": 38, "vol": 32, "pen": 48,
        "vis": 60, "cro": 50, "fk": 45, "sho_pas": 74, "lng_pas": 72, "cur": 48,
        "agi": 68, "bal": 66, "rea": 79, "bal_con": 71, "dri": 62, "com": 78,
        "int": 80, "hea": 80, "def_awa": 80, "std_tac": 81, "sld_tac": 80,
        "jmp": 81, "sta": 82, "str": 82, "agg": 80,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    927: {
        "name": "Do Phi Long",
        "pos": 5, "foot": 1, "wf": 3, "sm": 2, "h": 183, "w": 78,
        "ovr": 79, "pot": 83,
        "acc": 73, "spd": 74,
        "pos_att": 40, "fin": 35, "pow": 72, "lng_sho": 40, "vol": 35, "pen": 50,
        "vis": 62, "cro": 52, "fk": 48, "sho_pas": 75, "lng_pas": 73, "cur": 50,
        "agi": 66, "bal": 65, "rea": 80, "bal_con": 72, "dri": 64, "com": 79,
        "int": 81, "hea": 82, "def_awa": 81, "std_tac": 82, "sld_tac": 81,
        "jmp": 82, "sta": 83, "str": 84, "agg": 82,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },

    # ------------------ TIEN VE PHONG NGU / TRUNG TAM (CDM / CM) ------------------
    904: {
        "name": "Nguyen Trong Dai",
        "pos": 10, "foot": 1, "wf": 3, "sm": 2, "h": 184, "w": 76,  # CDM the hinh tot
        "ovr": 78, "pot": 82,
        "acc": 74, "spd": 75,
        "pos_att": 55, "fin": 52, "pow": 78, "lng_sho": 65, "vol": 52, "pen": 55,
        "vis": 74, "cro": 62, "fk": 60, "sho_pas": 80, "lng_pas": 78, "cur": 64,
        "agi": 68, "bal": 66, "rea": 79, "bal_con": 77, "dri": 72, "com": 79,
        "int": 81, "hea": 78, "def_awa": 80, "std_tac": 82, "sld_tac": 80,
        "jmp": 79, "sta": 84, "str": 83, "agg": 84,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    910: {
        "name": "Do Hung Dung",
        "pos": 10, "foot": 1, "wf": 4, "sm": 3, "h": 170, "w": 66,  # B2B can cu, the luc phi thuong
        "ovr": 80, "pot": 83,
        "acc": 76, "spd": 77,
        "pos_att": 74, "fin": 68, "pow": 76, "lng_sho": 74, "vol": 66, "pen": 70,
        "vis": 81, "cro": 75, "fk": 68, "sho_pas": 84, "lng_pas": 81, "cur": 73,
        "agi": 78, "bal": 78, "rea": 82, "bal_con": 80, "dri": 78, "com": 83,
        "int": 83, "hea": 72, "def_awa": 82, "std_tac": 83, "sld_tac": 81,
        "jmp": 75, "sta": 92, "str": 76, "agg": 82,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    913: {
        "name": "Nguyen Tuan Anh",
        "pos": 14, "foot": 1, "wf": 4, "sm": 4, "h": 176, "w": 68,  # CM thoat pressing, khéo léo
        "ovr": 79, "pot": 83,
        "acc": 75, "spd": 74,
        "pos_att": 72, "fin": 66, "pow": 75, "lng_sho": 72, "vol": 68, "pen": 68,
        "vis": 83, "cro": 74, "fk": 75, "sho_pas": 85, "lng_pas": 82, "cur": 78,
        "agi": 84, "bal": 82, "rea": 82, "bal_con": 85, "dri": 83, "com": 86,
        "int": 78, "hea": 65, "def_awa": 76, "std_tac": 78, "sld_tac": 75,
        "jmp": 72, "sta": 82, "str": 72, "agg": 76,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    916: {
        "name": "Luong Xuan Truong",
        "pos": 14, "foot": 1, "wf": 3, "sm": 3, "h": 178, "w": 72,  # CM chuyen dai + da phat dinh
        "ovr": 79, "pot": 82,
        "acc": 70, "spd": 69,
        "pos_att": 72, "fin": 68, "pow": 78, "lng_sho": 78, "vol": 70, "pen": 74,
        "vis": 86, "cro": 80, "fk": 85, "sho_pas": 84, "lng_pas": 86, "cur": 84,
        "agi": 74, "bal": 72, "rea": 79, "bal_con": 82, "dri": 78, "com": 84,
        "int": 72, "hea": 65, "def_awa": 70, "std_tac": 72, "sld_tac": 68,
        "jmp": 70, "sta": 80, "str": 73, "agg": 72,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },

    # ------------------ TIEN VE CONG / NHAC TRUONG (CAM / WINGER) ------------------
    903: {
        "name": "Nguyen Quang Hai",
        "pos": 18, "foot": 2, "wf": 3, "sm": 4, "h": 168, "w": 67,  # CAM/RW, Sieu pham, sut phat, kheo leo
        "ovr": 82, "pot": 85,
        "acc": 81, "spd": 78,
        "pos_att": 82, "fin": 82, "pow": 84, "lng_sho": 86, "vol": 80, "pen": 80,
        "vis": 86, "cro": 84, "fk": 88, "sho_pas": 85, "lng_pas": 83, "cur": 88,
        "agi": 87, "bal": 88, "rea": 83, "bal_con": 86, "dri": 85, "com": 85,
        "int": 52, "hea": 58, "def_awa": 48, "std_tac": 52, "sld_tac": 48,
        "jmp": 76, "sta": 82, "str": 70, "agg": 72,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    908: {
        "name": "Nguyen Hoang Duc",
        "pos": 14, "foot": 2, "wf": 4, "sm": 4, "h": 184, "w": 76,  # CM/CAM nhac truong, thoat pressing
        "ovr": 82, "pot": 86,
        "acc": 78, "spd": 77,
        "pos_att": 80, "fin": 76, "pow": 82, "lng_sho": 80, "vol": 76, "pen": 74,
        "vis": 87, "cro": 82, "fk": 78, "sho_pas": 87, "lng_pas": 85, "cur": 84,
        "agi": 82, "bal": 80, "rea": 84, "bal_con": 87, "dri": 85, "com": 86,
        "int": 75, "hea": 74, "def_awa": 72, "std_tac": 78, "sld_tac": 72,
        "jmp": 78, "sta": 85, "str": 80, "agg": 76,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    909: {
        "name": "Nguyen Cong Phuong",
        "pos": 21, "foot": 1, "wf": 4, "sm": 4, "h": 168, "w": 65,  # CF/RW re dat tao dot bien
        "ovr": 79, "pot": 82,
        "acc": 85, "spd": 83,
        "pos_att": 80, "fin": 79, "pow": 81, "lng_sho": 78, "vol": 74, "pen": 78,
        "vis": 78, "cro": 74, "fk": 79, "sho_pas": 79, "lng_pas": 72, "cur": 80,
        "agi": 87, "bal": 85, "rea": 80, "bal_con": 83, "dri": 85, "com": 80,
        "int": 35, "hea": 58, "def_awa": 32, "std_tac": 35, "sld_tac": 32,
        "jmp": 74, "sta": 80, "str": 67, "agg": 70,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    922: {
        "name": "Do Hoang Hen",
        "pos": 18, "foot": 2, "wf": 4, "sm": 4, "h": 181, "w": 74,  # Hendrio - Ky thuat Samba
        "ovr": 82, "pot": 85,
        "acc": 78, "spd": 77,
        "pos_att": 82, "fin": 80, "pow": 82, "lng_sho": 83, "vol": 78, "pen": 78,
        "vis": 86, "cro": 83, "fk": 84, "sho_pas": 86, "lng_pas": 84, "cur": 86,
        "agi": 84, "bal": 82, "rea": 83, "bal_con": 86, "dri": 86, "com": 85,
        "int": 65, "hea": 68, "def_awa": 62, "std_tac": 68, "sld_tac": 62,
        "jmp": 76, "sta": 84, "str": 76, "agg": 74,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    923: {
        "name": "Nguyen Dinh Bac",
        "pos": 27, "foot": 1, "wf": 3, "sm": 4, "h": 180, "w": 72,  # LW/ST tre, toc do, dot bien
        "ovr": 79, "pot": 87,
        "acc": 88, "spd": 87,
        "pos_att": 80, "fin": 79, "pow": 82, "lng_sho": 78, "vol": 72, "pen": 70,
        "vis": 76, "cro": 77, "fk": 70, "sho_pas": 78, "lng_pas": 72, "cur": 76,
        "agi": 85, "bal": 80, "rea": 80, "bal_con": 82, "dri": 83, "com": 78,
        "int": 42, "hea": 74, "def_awa": 38, "std_tac": 42, "sld_tac": 38,
        "jmp": 80, "sta": 84, "str": 75, "agg": 76,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    924: {
        "name": "Khuat Van Khang",
        "pos": 16, "foot": 2, "wf": 3, "sm": 4, "h": 171, "w": 66,  # LM/LW chan trai khéo
        "ovr": 78, "pot": 86,
        "acc": 84, "spd": 83,
        "pos_att": 76, "fin": 74, "pow": 78, "lng_sho": 76, "vol": 72, "pen": 72,
        "vis": 81, "cro": 82, "fk": 82, "sho_pas": 81, "lng_pas": 78, "cur": 82,
        "agi": 85, "bal": 82, "rea": 79, "bal_con": 81, "dri": 82, "com": 78,
        "int": 58, "hea": 62, "def_awa": 55, "std_tac": 60, "sld_tac": 56,
        "jmp": 74, "sta": 83, "str": 70, "agg": 74,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },

    # ------------------ TIEN DAO (ST / CF) ------------------
    912: {
        "name": "Nguyen Tien Linh",
        "pos": 25, "foot": 1, "wf": 4, "sm": 3, "h": 180, "w": 76,  # ST muc tieu, chon vi tri + danh dau
        "ovr": 81, "pot": 84,
        "acc": 77, "spd": 76,
        "pos_att": 86, "fin": 85, "pow": 84, "lng_sho": 78, "vol": 80, "pen": 78,
        "vis": 74, "cro": 65, "fk": 68, "sho_pas": 78, "lng_pas": 68, "cur": 70,
        "agi": 75, "bal": 74, "rea": 83, "bal_con": 81, "dri": 78, "com": 82,
        "int": 35, "hea": 86, "def_awa": 38, "std_tac": 36, "sld_tac": 32,
        "jmp": 84, "sta": 83, "str": 84, "agg": 78,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    917: {
        "name": "Pham Tuan Hai",
        "pos": 25, "foot": 1, "wf": 4, "sm": 3, "h": 172, "w": 70,  # ST/LW nang no, sut xa, pressing
        "ovr": 81, "pot": 86,
        "acc": 85, "spd": 84,
        "pos_att": 83, "fin": 83, "pow": 85, "lng_sho": 82, "vol": 78, "pen": 74,
        "vis": 76, "cro": 74, "fk": 70, "sho_pas": 78, "lng_pas": 70, "cur": 74,
        "agi": 84, "bal": 80, "rea": 83, "bal_con": 81, "dri": 81, "com": 81,
        "int": 52, "hea": 78, "def_awa": 48, "std_tac": 52, "sld_tac": 46,
        "jmp": 82, "sta": 91, "str": 82, "agg": 86,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    921: {
        "name": "Nguyen Xuan Son",
        "pos": 25, "foot": 1, "wf": 4, "sm": 3, "h": 185, "w": 86,  # Rafaelson sat thu vong cam, ti de
        "ovr": 83, "pot": 87,
        "acc": 79, "spd": 80,
        "pos_att": 88, "fin": 88, "pow": 88, "lng_sho": 84, "vol": 82, "pen": 84,
        "vis": 75, "cro": 68, "fk": 72, "sho_pas": 78, "lng_pas": 72, "cur": 74,
        "agi": 76, "bal": 78, "rea": 85, "bal_con": 83, "dri": 81, "com": 84,
        "int": 38, "hea": 86, "def_awa": 35, "std_tac": 38, "sld_tac": 32,
        "jmp": 84, "sta": 85, "str": 89, "agg": 85,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    },
    928: {
        "name": "Nguyen Tai Loc",
        "pos": 25, "foot": 1, "wf": 3, "sm": 3, "h": 180, "w": 75,
        "ovr": 80, "pot": 83,
        "acc": 78, "spd": 78,
        "pos_att": 82, "fin": 82, "pow": 83, "lng_sho": 78, "vol": 74, "pen": 74,
        "vis": 74, "cro": 68, "fk": 65, "sho_pas": 77, "lng_pas": 68, "cur": 70,
        "agi": 76, "bal": 75, "rea": 81, "bal_con": 79, "dri": 78, "com": 80,
        "int": 35, "hea": 80, "def_awa": 35, "std_tac": 36, "sld_tac": 32,
        "jmp": 80, "sta": 83, "str": 82, "agg": 78,
        "gkd": 10, "gkh": 10, "gkk": 10, "gkp": 10, "gkr": 10
    }
}

def generate_lua():
    lines = [
        "-- lua/autorun/buff_vietnam_squad.lua",
        "-- Script tu dong buff & chuan hoa 29 cau thu Viet Nam len dang cap Cup C1 (OVR 79 - 83)",
        "-- Tu dong load khi Live Editor khoi dong hoac chay truc tiep trong Lua Engine",
        "",
        "local BUFFS = {"
    ]

    for pid, d in sorted(BUFF_DATA.items()):
        lines.append(f"    [{pid}] = {{ -- {d['name']}")
        alt = ALT_POS.get(pid, {})
        alt_str = f", preferredposition2 = {alt['alt1']}" if alt.get('alt1', -1) > 0 else ""
        if alt.get('alt2', -1) > 0: alt_str += f", preferredposition3 = {alt['alt2']}"
        lines.append(f"        overallrating = {d['ovr']}, potential = {d['pot']}, preferredposition1 = {d['pos']}{alt_str},")
        lines.append(f"        preferredfoot = {d['foot']}, weakfootabilitycode = {d['wf']}, skillmoves = {d['sm']},")
        lines.append(f"        height = {d['h']}, weight = {d['w']},")
        lines.append(f"        acceleration = {d['acc']}, sprintspeed = {d['spd']},")
        lines.append(f"        positioning = {d['pos_att']}, finishing = {d['fin']}, shotpower = {d['pow']},")
        lines.append(f"        longshots = {d['lng_sho']}, volleys = {d['vol']}, penalties = {d['pen']},")
        lines.append(f"        vision = {d['vis']}, crossing = {d['cro']}, freekickaccuracy = {d['fk']},")
        lines.append(f"        shortpassing = {d['sho_pas']}, longpassing = {d['lng_pas']}, curve = {d['cur']},")
        lines.append(f"        agility = {d['agi']}, balance = {d['bal']}, reactions = {d['rea']},")
        lines.append(f"        ballcontrol = {d['bal_con']}, dribbling = {d['dri']}, composure = {d['com']},")
        lines.append(f"        interceptions = {d['int']}, headingaccuracy = {d['hea']}, defensiveawareness = {d['def_awa']},")
        lines.append(f"        standingtackle = {d['std_tac']}, slidingtackle = {d['sld_tac']},")
        lines.append(f"        jumping = {d['jmp']}, stamina = {d['sta']}, strength = {d['str']}, aggression = {d['agg']},")
        lines.append(f"        gkdiving = {d['gkd']}, gkhandling = {d['gkh']}, gkkicking = {d['gkk']},")
        lines.append(f"        gkpositioning = {d['gkp']}, gkreflexes = {d['gkr']}")
        lines.append("    },")

    lines.append("}")
    lines.append("""
local function safe_edit(field, val)
    if field and field.value ~= nil then
        field.value = tostring(val)
        if type(EditDBTableField) == "function" then
            EditDBTableField(field)
        end
    end
end

local function apply_vn_buffs()
    local rows = type(GetDBTableRows) == "function" and GetDBTableRows("players") or nil
    if not rows then
        print("[VN Buff] ERROR: Khong lay duoc bang 'players' tu RAM!")
        return
    end

    local count = 0
    for i = 1, #rows do
        local p = rows[i]
        local pid = p.playerid and math.floor(tonumber(p.playerid.value) or 0) or 0
        local buff = BUFFS[pid]

        if buff then
            for field, val in pairs(buff) do
                if p[field] then
                    safe_edit(p[field], val)
                end
            end
            count = count + 1
        end
    end

    local msg = string.format("[VN Buff] DA BUFF THANH CONG %d / %d CAU THU VIET NAM LEN CHUAN C1!", count, 29)
    print(msg)
    pcall(function()
        local f = io.open("C:/FC 26 Live Editor/viet_hoa_log.txt", "a")
        if f then
            f:write(msg .. "\\n")
            f:close()
        end
    end)
end

apply_vn_buffs()
""")

    content = "\n".join(lines)
    
    # Ghi vao thu muc lua/autorun cua du an
    out1 = ROOT / "lua" / "buff_vietnam_squad.lua"
    out1.write_text(content, encoding="utf-8")
    print(f"Da tao: {out1}")

    # Ghi truc tiep vao thu muc Live Editor
    out2 = Path("C:/FC 26 Live Editor/lua/autorun/buff_vietnam_squad.lua")
    try:
        out2.parent.mkdir(parents=True, exist_ok=True)
        out2.write_text(content, encoding="utf-8")
        print(f"Da copy truc tiep vao Live Editor autorun: {out2}")
    except Exception as e:
        print(f"Khong the copy vao Live Editor autorun: {e}")

if __name__ == "__main__":
    generate_lua()
