-- Rank brackets mapping class points to rank strings and names.
SPZ.RankBrackets = {
    [0] = {   -- Class C
        { threshold = 0,   rank = "C-5", name = "Rookie"      },
        { threshold = 100, rank = "C-4", name = "Newcomer"    },
        { threshold = 200, rank = "C-3", name = "Amateur"     },
        { threshold = 300, rank = "C-2", name = "Club Racer"  },
        { threshold = 400, rank = "C-1", name = "Street King" },
    },
    [1] = {   -- Class B
        { threshold = 0,   rank = "B-5", name = "Sport Driver"  },
        { threshold = 200, rank = "B-4", name = "Circuit Racer" },
        { threshold = 400, rank = "B-3", name = "Hotshoe"       },
        { threshold = 600, rank = "B-2", name = "Racer"         },
        { threshold = 800, rank = "B-1", name = "Speed Demon"   },
    },
    [2] = {   -- Class A
        { threshold = 0,    rank = "A-5", name = "Pro Driver"   },
        { threshold = 400,  rank = "A-4", name = "Wheelman"     },
        { threshold = 800,  rank = "A-3", name = "Grand Tourer" },
        { threshold = 1200, rank = "A-2", name = "Elite Racer"  },
        { threshold = 1600, rank = "A-1", name = "Ace"          },
    },
    [3] = {   -- Class S
        { threshold = 0,    rank = "S-5", name = "Supercar Driver" },
        { threshold = 500,  rank = "S-4", name = "The Specialist"  },
        { threshold = 1000, rank = "S-3", name = "Champion"        },
        { threshold = 1500, rank = "S-2", name = "Legend"          },
        { threshold = 2000, rank = "S-1", name = "The SPiceZ"      },
    },
}
