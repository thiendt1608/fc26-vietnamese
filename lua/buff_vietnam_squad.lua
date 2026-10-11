-- lua/autorun/buff_vietnam_squad.lua
-- Script tu dong buff & chuan hoa 29 cau thu Viet Nam len dang cap Cup C1 (OVR 79 - 83)
-- Tu dong load khi Live Editor khoi dong hoac chay truc tiep trong Lua Engine

local BUFFS = {
    [900] = { -- Dang Van Lam
        overallrating = 81, potential = 85, preferredposition1 = 0,
        preferredfoot = 2, weakfootabilitycode = 3, skillmoves = 1,
        height = 188, weight = 86,
        acceleration = 45, sprintspeed = 46,
        positioning = 15, finishing = 15, shotpower = 68,
        longshots = 18, volleys = 16, penalties = 35,
        vision = 52, crossing = 22, freekickaccuracy = 25,
        shortpassing = 42, longpassing = 58, curve = 24,
        agility = 62, balance = 58, reactions = 83,
        ballcontrol = 42, dribbling = 25, composure = 78,
        interceptions = 25, headingaccuracy = 32, defensiveawareness = 22,
        standingtackle = 20, slidingtackle = 18,
        jumping = 76, stamina = 65, strength = 82, aggression = 48,
        gkdiving = 82, gkhandling = 80, gkkicking = 78,
        gkpositioning = 81, gkreflexes = 84
    },
    [901] = { -- Nguyen Van Toan
        overallrating = 80, potential = 85, preferredposition1 = 23, preferredposition2 = 25, preferredposition3 = 12,
        preferredfoot = 1, weakfootabilitycode = 3, skillmoves = 4,
        height = 170, weight = 65,
        acceleration = 92, sprintspeed = 91,
        positioning = 82, finishing = 75, shotpower = 77,
        longshots = 74, volleys = 70, penalties = 68,
        vision = 76, crossing = 77, freekickaccuracy = 65,
        shortpassing = 78, longpassing = 68, curve = 72,
        agility = 89, balance = 86, reactions = 82,
        ballcontrol = 82, dribbling = 83, composure = 77,
        interceptions = 38, headingaccuracy = 58, defensiveawareness = 35,
        standingtackle = 36, slidingtackle = 34,
        jumping = 74, stamina = 86, strength = 66, aggression = 68,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [902] = { -- Ho Tan Tai
        overallrating = 79, potential = 83, preferredposition1 = 3, preferredposition2 = 2, preferredposition3 = 12,
        preferredfoot = 1, weakfootabilitycode = 3, skillmoves = 3,
        height = 180, weight = 74,
        acceleration = 82, sprintspeed = 83,
        positioning = 74, finishing = 65, shotpower = 76,
        longshots = 68, volleys = 62, penalties = 60,
        vision = 74, crossing = 81, freekickaccuracy = 62,
        shortpassing = 79, longpassing = 74, curve = 72,
        agility = 76, balance = 74, reactions = 80,
        ballcontrol = 78, dribbling = 77, composure = 78,
        interceptions = 80, headingaccuracy = 78, defensiveawareness = 79,
        standingtackle = 81, slidingtackle = 79,
        jumping = 80, stamina = 86, strength = 78, aggression = 78,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [903] = { -- Nguyen Quang Hai
        overallrating = 82, potential = 85, preferredposition1 = 18, preferredposition2 = 23, preferredposition3 = 27,
        preferredfoot = 2, weakfootabilitycode = 3, skillmoves = 4,
        height = 168, weight = 67,
        acceleration = 81, sprintspeed = 78,
        positioning = 82, finishing = 82, shotpower = 84,
        longshots = 86, volleys = 80, penalties = 80,
        vision = 86, crossing = 84, freekickaccuracy = 88,
        shortpassing = 85, longpassing = 83, curve = 88,
        agility = 87, balance = 88, reactions = 83,
        ballcontrol = 86, dribbling = 85, composure = 85,
        interceptions = 52, headingaccuracy = 58, defensiveawareness = 48,
        standingtackle = 52, slidingtackle = 48,
        jumping = 76, stamina = 82, strength = 70, aggression = 72,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [904] = { -- Nguyen Trong Dai
        overallrating = 78, potential = 82, preferredposition1 = 10,
        preferredfoot = 1, weakfootabilitycode = 3, skillmoves = 2,
        height = 184, weight = 76,
        acceleration = 74, sprintspeed = 75,
        positioning = 55, finishing = 52, shotpower = 78,
        longshots = 65, volleys = 52, penalties = 55,
        vision = 74, crossing = 62, freekickaccuracy = 60,
        shortpassing = 80, longpassing = 78, curve = 64,
        agility = 68, balance = 66, reactions = 79,
        ballcontrol = 77, dribbling = 72, composure = 79,
        interceptions = 81, headingaccuracy = 78, defensiveawareness = 80,
        standingtackle = 82, slidingtackle = 80,
        jumping = 79, stamina = 84, strength = 83, aggression = 84,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [905] = { -- Doan Van Hau
        overallrating = 81, potential = 85, preferredposition1 = 7, preferredposition2 = 5, preferredposition3 = 8,
        preferredfoot = 2, weakfootabilitycode = 3, skillmoves = 3,
        height = 185, weight = 82,
        acceleration = 84, sprintspeed = 85,
        positioning = 76, finishing = 68, shotpower = 84,
        longshots = 80, volleys = 68, penalties = 65,
        vision = 76, crossing = 83, freekickaccuracy = 74,
        shortpassing = 80, longpassing = 77, curve = 78,
        agility = 75, balance = 74, reactions = 81,
        ballcontrol = 79, dribbling = 78, composure = 80,
        interceptions = 82, headingaccuracy = 83, defensiveawareness = 81,
        standingtackle = 83, slidingtackle = 82,
        jumping = 84, stamina = 87, strength = 86, aggression = 86,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [906] = { -- Vu Van Thanh
        overallrating = 79, potential = 83, preferredposition1 = 3, preferredposition2 = 7, preferredposition3 = 2,
        preferredfoot = 1, weakfootabilitycode = 4, skillmoves = 3,
        height = 170, weight = 69,
        acceleration = 84, sprintspeed = 83,
        positioning = 75, finishing = 70, shotpower = 80,
        longshots = 75, volleys = 66, penalties = 72,
        vision = 74, crossing = 80, freekickaccuracy = 68,
        shortpassing = 79, longpassing = 73, curve = 74,
        agility = 82, balance = 80, reactions = 79,
        ballcontrol = 78, dribbling = 78, composure = 77,
        interceptions = 79, headingaccuracy = 72, defensiveawareness = 78,
        standingtackle = 80, slidingtackle = 79,
        jumping = 78, stamina = 88, strength = 79, aggression = 80,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [907] = { -- B H Viet Anh
        overallrating = 81, potential = 86, preferredposition1 = 5, preferredposition2 = 10,
        preferredfoot = 1, weakfootabilitycode = 3, skillmoves = 2,
        height = 186, weight = 80,
        acceleration = 76, sprintspeed = 77,
        positioning = 40, finishing = 40, shotpower = 72,
        longshots = 45, volleys = 38, penalties = 55,
        vision = 65, crossing = 52, freekickaccuracy = 50,
        shortpassing = 76, longpassing = 74, curve = 55,
        agility = 68, balance = 66, reactions = 82,
        ballcontrol = 74, dribbling = 66, composure = 82,
        interceptions = 84, headingaccuracy = 85, defensiveawareness = 84,
        standingtackle = 85, slidingtackle = 83,
        jumping = 85, stamina = 84, strength = 87, aggression = 84,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [908] = { -- Nguyen Hoang Duc
        overallrating = 82, potential = 86, preferredposition1 = 14, preferredposition2 = 18, preferredposition3 = 10,
        preferredfoot = 2, weakfootabilitycode = 4, skillmoves = 4,
        height = 184, weight = 76,
        acceleration = 78, sprintspeed = 77,
        positioning = 80, finishing = 76, shotpower = 82,
        longshots = 80, volleys = 76, penalties = 74,
        vision = 87, crossing = 82, freekickaccuracy = 78,
        shortpassing = 87, longpassing = 85, curve = 84,
        agility = 82, balance = 80, reactions = 84,
        ballcontrol = 87, dribbling = 85, composure = 86,
        interceptions = 75, headingaccuracy = 74, defensiveawareness = 72,
        standingtackle = 78, slidingtackle = 72,
        jumping = 78, stamina = 85, strength = 80, aggression = 76,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [909] = { -- Nguyen Cong Phuong
        overallrating = 79, potential = 82, preferredposition1 = 21, preferredposition2 = 23, preferredposition3 = 27,
        preferredfoot = 1, weakfootabilitycode = 4, skillmoves = 4,
        height = 168, weight = 65,
        acceleration = 85, sprintspeed = 83,
        positioning = 80, finishing = 79, shotpower = 81,
        longshots = 78, volleys = 74, penalties = 78,
        vision = 78, crossing = 74, freekickaccuracy = 79,
        shortpassing = 79, longpassing = 72, curve = 80,
        agility = 87, balance = 85, reactions = 80,
        ballcontrol = 83, dribbling = 85, composure = 80,
        interceptions = 35, headingaccuracy = 58, defensiveawareness = 32,
        standingtackle = 35, slidingtackle = 32,
        jumping = 74, stamina = 80, strength = 67, aggression = 70,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [910] = { -- Do Hung Dung
        overallrating = 80, potential = 83, preferredposition1 = 10, preferredposition2 = 10,
        preferredfoot = 1, weakfootabilitycode = 4, skillmoves = 3,
        height = 170, weight = 66,
        acceleration = 76, sprintspeed = 77,
        positioning = 74, finishing = 68, shotpower = 76,
        longshots = 74, volleys = 66, penalties = 70,
        vision = 81, crossing = 75, freekickaccuracy = 68,
        shortpassing = 84, longpassing = 81, curve = 73,
        agility = 78, balance = 78, reactions = 82,
        ballcontrol = 80, dribbling = 78, composure = 83,
        interceptions = 83, headingaccuracy = 72, defensiveawareness = 82,
        standingtackle = 83, slidingtackle = 81,
        jumping = 75, stamina = 92, strength = 76, aggression = 82,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [911] = { -- Do Duy Manh
        overallrating = 80, potential = 84, preferredposition1 = 5, preferredposition2 = 10, preferredposition3 = 3,
        preferredfoot = 1, weakfootabilitycode = 3, skillmoves = 2,
        height = 180, weight = 75,
        acceleration = 75, sprintspeed = 74,
        positioning = 42, finishing = 38, shotpower = 75,
        longshots = 46, volleys = 40, penalties = 58,
        vision = 66, crossing = 55, freekickaccuracy = 55,
        shortpassing = 76, longpassing = 75, curve = 56,
        agility = 67, balance = 65, reactions = 81,
        ballcontrol = 72, dribbling = 64, composure = 80,
        interceptions = 83, headingaccuracy = 83, defensiveawareness = 82,
        standingtackle = 84, slidingtackle = 83,
        jumping = 83, stamina = 83, strength = 85, aggression = 88,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [912] = { -- Nguyen Tien Linh
        overallrating = 81, potential = 84, preferredposition1 = 25, preferredposition2 = 21,
        preferredfoot = 1, weakfootabilitycode = 4, skillmoves = 3,
        height = 180, weight = 76,
        acceleration = 77, sprintspeed = 76,
        positioning = 86, finishing = 85, shotpower = 84,
        longshots = 78, volleys = 80, penalties = 78,
        vision = 74, crossing = 65, freekickaccuracy = 68,
        shortpassing = 78, longpassing = 68, curve = 70,
        agility = 75, balance = 74, reactions = 83,
        ballcontrol = 81, dribbling = 78, composure = 82,
        interceptions = 35, headingaccuracy = 86, defensiveawareness = 38,
        standingtackle = 36, slidingtackle = 32,
        jumping = 84, stamina = 83, strength = 84, aggression = 78,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [913] = { -- Nguyen Tuan Anh
        overallrating = 79, potential = 83, preferredposition1 = 14, preferredposition2 = 10,
        preferredfoot = 1, weakfootabilitycode = 4, skillmoves = 4,
        height = 176, weight = 68,
        acceleration = 75, sprintspeed = 74,
        positioning = 72, finishing = 66, shotpower = 75,
        longshots = 72, volleys = 68, penalties = 68,
        vision = 83, crossing = 74, freekickaccuracy = 75,
        shortpassing = 85, longpassing = 82, curve = 78,
        agility = 84, balance = 82, reactions = 82,
        ballcontrol = 85, dribbling = 83, composure = 86,
        interceptions = 78, headingaccuracy = 65, defensiveawareness = 76,
        standingtackle = 78, slidingtackle = 75,
        jumping = 72, stamina = 82, strength = 72, aggression = 76,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [914] = { -- Bui Tien Dung
        overallrating = 79, potential = 83, preferredposition1 = 5,
        preferredfoot = 1, weakfootabilitycode = 3, skillmoves = 2,
        height = 176, weight = 72,
        acceleration = 75, sprintspeed = 74,
        positioning = 38, finishing = 35, shotpower = 68,
        longshots = 40, volleys = 35, penalties = 52,
        vision = 64, crossing = 48, freekickaccuracy = 46,
        shortpassing = 75, longpassing = 72, curve = 50,
        agility = 70, balance = 69, reactions = 81,
        ballcontrol = 72, dribbling = 63, composure = 81,
        interceptions = 83, headingaccuracy = 81, defensiveawareness = 82,
        standingtackle = 83, slidingtackle = 82,
        jumping = 82, stamina = 83, strength = 83, aggression = 82,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [915] = { -- Que Ngoc Hai
        overallrating = 81, potential = 84, preferredposition1 = 5, preferredposition2 = 10,
        preferredfoot = 1, weakfootabilitycode = 3, skillmoves = 2,
        height = 182, weight = 78,
        acceleration = 74, sprintspeed = 75,
        positioning = 45, finishing = 42, shotpower = 78,
        longshots = 52, volleys = 45, penalties = 68,
        vision = 74, crossing = 62, freekickaccuracy = 65,
        shortpassing = 80, longpassing = 81, curve = 65,
        agility = 66, balance = 65, reactions = 83,
        ballcontrol = 75, dribbling = 67, composure = 85,
        interceptions = 85, headingaccuracy = 84, defensiveawareness = 85,
        standingtackle = 85, slidingtackle = 84,
        jumping = 84, stamina = 84, strength = 86, aggression = 87,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [916] = { -- Luong Xuan Truong
        overallrating = 79, potential = 82, preferredposition1 = 14,
        preferredfoot = 1, weakfootabilitycode = 3, skillmoves = 3,
        height = 178, weight = 72,
        acceleration = 70, sprintspeed = 69,
        positioning = 72, finishing = 68, shotpower = 78,
        longshots = 78, volleys = 70, penalties = 74,
        vision = 86, crossing = 80, freekickaccuracy = 85,
        shortpassing = 84, longpassing = 86, curve = 84,
        agility = 74, balance = 72, reactions = 79,
        ballcontrol = 82, dribbling = 78, composure = 84,
        interceptions = 72, headingaccuracy = 65, defensiveawareness = 70,
        standingtackle = 72, slidingtackle = 68,
        jumping = 70, stamina = 80, strength = 73, aggression = 72,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [917] = { -- Pham Tuan Hai
        overallrating = 81, potential = 86, preferredposition1 = 25, preferredposition2 = 27, preferredposition3 = 21,
        preferredfoot = 1, weakfootabilitycode = 4, skillmoves = 3,
        height = 172, weight = 70,
        acceleration = 85, sprintspeed = 84,
        positioning = 83, finishing = 83, shotpower = 85,
        longshots = 82, volleys = 78, penalties = 74,
        vision = 76, crossing = 74, freekickaccuracy = 70,
        shortpassing = 78, longpassing = 70, curve = 74,
        agility = 84, balance = 80, reactions = 83,
        ballcontrol = 81, dribbling = 81, composure = 81,
        interceptions = 52, headingaccuracy = 78, defensiveawareness = 48,
        standingtackle = 52, slidingtackle = 46,
        jumping = 82, stamina = 91, strength = 82, aggression = 86,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [918] = { -- Nguyen Thanh Chung
        overallrating = 79, potential = 82, preferredposition1 = 5, preferredposition2 = 25,
        preferredfoot = 1, weakfootabilitycode = 3, skillmoves = 2,
        height = 182, weight = 77,
        acceleration = 74, sprintspeed = 73,
        positioning = 55, finishing = 52, shotpower = 76,
        longshots = 50, volleys = 48, penalties = 58,
        vision = 62, crossing = 48, freekickaccuracy = 48,
        shortpassing = 74, longpassing = 72, curve = 52,
        agility = 65, balance = 64, reactions = 80,
        ballcontrol = 71, dribbling = 63, composure = 80,
        interceptions = 81, headingaccuracy = 86, defensiveawareness = 81,
        standingtackle = 82, slidingtackle = 80,
        jumping = 85, stamina = 82, strength = 85, aggression = 83,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [919] = { -- Bui Tan Truong
        overallrating = 79, potential = 82, preferredposition1 = 0,
        preferredfoot = 1, weakfootabilitycode = 3, skillmoves = 1,
        height = 188, weight = 84,
        acceleration = 40, sprintspeed = 40,
        positioning = 14, finishing = 12, shotpower = 64,
        longshots = 15, volleys = 14, penalties = 30,
        vision = 48, crossing = 20, freekickaccuracy = 22,
        shortpassing = 38, longpassing = 52, curve = 20,
        agility = 56, balance = 52, reactions = 80,
        ballcontrol = 38, dribbling = 22, composure = 76,
        interceptions = 22, headingaccuracy = 28, defensiveawareness = 20,
        standingtackle = 18, slidingtackle = 16,
        jumping = 74, stamina = 60, strength = 80, aggression = 45,
        gkdiving = 79, gkhandling = 78, gkkicking = 75,
        gkpositioning = 80, gkreflexes = 81
    },
    [920] = { -- Phi Minh Long
        overallrating = 78, potential = 83, preferredposition1 = 0,
        preferredfoot = 1, weakfootabilitycode = 3, skillmoves = 1,
        height = 180, weight = 75,
        acceleration = 42, sprintspeed = 42,
        positioning = 14, finishing = 12, shotpower = 60,
        longshots = 14, volleys = 14, penalties = 28,
        vision = 46, crossing = 18, freekickaccuracy = 20,
        shortpassing = 36, longpassing = 48, curve = 18,
        agility = 60, balance = 56, reactions = 79,
        ballcontrol = 36, dribbling = 20, composure = 74,
        interceptions = 20, headingaccuracy = 26, defensiveawareness = 18,
        standingtackle = 16, slidingtackle = 15,
        jumping = 72, stamina = 58, strength = 75, aggression = 42,
        gkdiving = 78, gkhandling = 77, gkkicking = 74,
        gkpositioning = 78, gkreflexes = 80
    },
    [921] = { -- Nguyen Xuan Son
        overallrating = 83, potential = 87, preferredposition1 = 25, preferredposition2 = 21,
        preferredfoot = 1, weakfootabilitycode = 4, skillmoves = 3,
        height = 185, weight = 86,
        acceleration = 79, sprintspeed = 80,
        positioning = 88, finishing = 88, shotpower = 88,
        longshots = 84, volleys = 82, penalties = 84,
        vision = 75, crossing = 68, freekickaccuracy = 72,
        shortpassing = 78, longpassing = 72, curve = 74,
        agility = 76, balance = 78, reactions = 85,
        ballcontrol = 83, dribbling = 81, composure = 84,
        interceptions = 38, headingaccuracy = 86, defensiveawareness = 35,
        standingtackle = 38, slidingtackle = 32,
        jumping = 84, stamina = 85, strength = 89, aggression = 85,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [922] = { -- Do Hoang Hen
        overallrating = 82, potential = 85, preferredposition1 = 18, preferredposition2 = 14, preferredposition3 = 12,
        preferredfoot = 2, weakfootabilitycode = 4, skillmoves = 4,
        height = 181, weight = 74,
        acceleration = 78, sprintspeed = 77,
        positioning = 82, finishing = 80, shotpower = 82,
        longshots = 83, volleys = 78, penalties = 78,
        vision = 86, crossing = 83, freekickaccuracy = 84,
        shortpassing = 86, longpassing = 84, curve = 86,
        agility = 84, balance = 82, reactions = 83,
        ballcontrol = 86, dribbling = 86, composure = 85,
        interceptions = 65, headingaccuracy = 68, defensiveawareness = 62,
        standingtackle = 68, slidingtackle = 62,
        jumping = 76, stamina = 84, strength = 76, aggression = 74,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [923] = { -- Nguyen Dinh Bac
        overallrating = 79, potential = 87, preferredposition1 = 27, preferredposition2 = 25, preferredposition3 = 23,
        preferredfoot = 1, weakfootabilitycode = 3, skillmoves = 4,
        height = 180, weight = 72,
        acceleration = 88, sprintspeed = 87,
        positioning = 80, finishing = 79, shotpower = 82,
        longshots = 78, volleys = 72, penalties = 70,
        vision = 76, crossing = 77, freekickaccuracy = 70,
        shortpassing = 78, longpassing = 72, curve = 76,
        agility = 85, balance = 80, reactions = 80,
        ballcontrol = 82, dribbling = 83, composure = 78,
        interceptions = 42, headingaccuracy = 74, defensiveawareness = 38,
        standingtackle = 42, slidingtackle = 38,
        jumping = 80, stamina = 84, strength = 75, aggression = 76,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [924] = { -- Khuat Van Khang
        overallrating = 78, potential = 86, preferredposition1 = 16, preferredposition2 = 27, preferredposition3 = 14,
        preferredfoot = 2, weakfootabilitycode = 3, skillmoves = 4,
        height = 171, weight = 66,
        acceleration = 84, sprintspeed = 83,
        positioning = 76, finishing = 74, shotpower = 78,
        longshots = 76, volleys = 72, penalties = 72,
        vision = 81, crossing = 82, freekickaccuracy = 82,
        shortpassing = 81, longpassing = 78, curve = 82,
        agility = 85, balance = 82, reactions = 79,
        ballcontrol = 81, dribbling = 82, composure = 78,
        interceptions = 58, headingaccuracy = 62, defensiveawareness = 55,
        standingtackle = 60, slidingtackle = 56,
        jumping = 74, stamina = 83, strength = 70, aggression = 74,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [925] = { -- Nguyen Van Vi
        overallrating = 79, potential = 82, preferredposition1 = 7, preferredposition2 = 16, preferredposition3 = 8,
        preferredfoot = 2, weakfootabilitycode = 3, skillmoves = 3,
        height = 169, weight = 65,
        acceleration = 88, sprintspeed = 87,
        positioning = 72, finishing = 62, shotpower = 74,
        longshots = 68, volleys = 60, penalties = 58,
        vision = 73, crossing = 80, freekickaccuracy = 65,
        shortpassing = 78, longpassing = 72, curve = 74,
        agility = 84, balance = 82, reactions = 78,
        ballcontrol = 77, dribbling = 79, composure = 76,
        interceptions = 78, headingaccuracy = 68, defensiveawareness = 78,
        standingtackle = 79, slidingtackle = 78,
        jumping = 76, stamina = 86, strength = 72, aggression = 76,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [926] = { -- Nguyen Nhat Minh
        overallrating = 78, potential = 84, preferredposition1 = 5,
        preferredfoot = 2, weakfootabilitycode = 3, skillmoves = 2,
        height = 180, weight = 75,
        acceleration = 74, sprintspeed = 75,
        positioning = 38, finishing = 32, shotpower = 70,
        longshots = 38, volleys = 32, penalties = 48,
        vision = 60, crossing = 50, freekickaccuracy = 45,
        shortpassing = 74, longpassing = 72, curve = 48,
        agility = 68, balance = 66, reactions = 79,
        ballcontrol = 71, dribbling = 62, composure = 78,
        interceptions = 80, headingaccuracy = 80, defensiveawareness = 80,
        standingtackle = 81, slidingtackle = 80,
        jumping = 81, stamina = 82, strength = 82, aggression = 80,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [927] = { -- Do Phi Long
        overallrating = 79, potential = 83, preferredposition1 = 5,
        preferredfoot = 1, weakfootabilitycode = 3, skillmoves = 2,
        height = 183, weight = 78,
        acceleration = 73, sprintspeed = 74,
        positioning = 40, finishing = 35, shotpower = 72,
        longshots = 40, volleys = 35, penalties = 50,
        vision = 62, crossing = 52, freekickaccuracy = 48,
        shortpassing = 75, longpassing = 73, curve = 50,
        agility = 66, balance = 65, reactions = 80,
        ballcontrol = 72, dribbling = 64, composure = 79,
        interceptions = 81, headingaccuracy = 82, defensiveawareness = 81,
        standingtackle = 82, slidingtackle = 81,
        jumping = 82, stamina = 83, strength = 84, aggression = 82,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
    [928] = { -- Nguyen Tai Loc
        overallrating = 80, potential = 83, preferredposition1 = 25, preferredposition2 = 18, preferredposition3 = 23,
        preferredfoot = 1, weakfootabilitycode = 3, skillmoves = 3,
        height = 180, weight = 75,
        acceleration = 78, sprintspeed = 78,
        positioning = 82, finishing = 82, shotpower = 83,
        longshots = 78, volleys = 74, penalties = 74,
        vision = 74, crossing = 68, freekickaccuracy = 65,
        shortpassing = 77, longpassing = 68, curve = 70,
        agility = 76, balance = 75, reactions = 81,
        ballcontrol = 79, dribbling = 78, composure = 80,
        interceptions = 35, headingaccuracy = 80, defensiveawareness = 35,
        standingtackle = 36, slidingtackle = 32,
        jumping = 80, stamina = 83, strength = 82, aggression = 78,
        gkdiving = 10, gkhandling = 10, gkkicking = 10,
        gkpositioning = 10, gkreflexes = 10
    },
}

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
            f:write(msg .. "\n")
            f:close()
        end
    end)
end

apply_vn_buffs()
