getSprites macro


dim_sprite_jug    db   08, 08 
data_sprite_jug   db  0B8,0B8,01F,01F,0B8,0B8,0B8,0B8
                  db  0B8,01F,01F,01F,01F,0B8,0B8,0B8
                  db  01F,000,01F,000,01F,01F,0B8,0B8
                  db  01F,000,01F,000,01F,01F,0B8,0B8
                  db  01F,01F,01F,01F,01F,01F,0B8,0B8
                  db  0B8,01F,01F,01F,01F,0B8,0B8,0B8
                  db  0B8,0B8,0B8,01F,01F,0B8,01F,0B8
                  db  0B8,0B8,0B8,0B8,01F,01F,0B8,0B8
dim_sprite_flcha  db   08, 08
data_sprite_flcha   db   00, 00, 03, 00, 00, 00, 00, 00
                    db   00, 00, 03, 03, 00, 00, 00, 00
                    db   03, 03, 03, 03, 03, 00, 00, 00
                    db   03, 03, 03, 03, 03, 03, 00, 00
                    db   03, 03, 03, 03, 03, 03, 00, 00
                    db   03, 03, 03, 03, 03, 00, 00, 00
                    db   00, 00, 03, 03, 00, 00, 00, 00
                    db   00, 00, 03, 00, 00, 00, 00, 00
dim_sprite_vacio  db   08, 08
data_sprite_vacio db   00, 00, 00, 00, 00, 00, 00, 00
                  db   00, 00, 00, 00, 00, 00, 00, 00
                  db   00, 00, 00, 00, 00, 00, 00, 00
                  db   00, 00, 00, 00, 00, 00, 00, 00
                  db   00, 00, 00, 00, 00, 00, 00, 00
                  db   00, 00, 00, 00, 00, 00, 00, 00
                  db   00, 00, 00, 00, 00, 00, 00, 00
                  db   00, 00, 00, 00, 00, 00, 00, 00
dim_sprite_suelo  db   08, 08
data_sprite_suelo db   0B8, 0B8, 0B8, 0B8, 0B8, 0B8, 0B8, 0B8
                  db   0B8, 0B8, 0B8, 0B8, 0B8, 0B8, 0B8, 0B8
                  db   0B8, 0B8, 0B8, 0B8, 0B8, 0B8, 0B8, 0B8
                  db   0B8, 0B8, 0B8, 0B8, 0B8, 0B8, 0B8, 0B8
                  db   0B8, 0B8, 0B8, 0B8, 0B8, 0B8, 0B8, 0B8
                  db   0B8, 0B8, 0B8, 0B8, 0B8, 0B8, 0B8, 0B8
                  db   0B8, 0B8, 0B8, 0B8, 0B8, 0B8, 0B8, 0B8
                  db   0B8, 0B8, 0B8, 0B8, 0B8, 0B8, 0B8, 0B8
dim_sprite_pared  db   08, 08 

data_sprite_pared db   1A, 1A, 1A, 1A, 12, 1E, 1A, 1A
                  db   1A, 1A, 1A, 1A, 12, 1E, 1A, 1A
                  db   14, 14, 14, 14, 12, 14, 1A, 1A
                  db   12, 12, 12, 12, 12, 12, 12, 12
                  db   12, 1E, 1E, 1E, 1E, 1E, 1E, 1E
                  db   12, 1E, 1A, 1A, 1A, 1A, 1A, 1A
                  db   12, 12, 12, 12, 12, 12, 12, 12
                  db   1E, 1E, 1E, 12, 1E, 1E, 1E, 1E

dim_sprite_caja   db   08, 08
data_sprite_caja  db  0b8,0b8,0b8,0b8,0b8,0b8,0b8,0b8
                  db  0b8,0b8,0b8,0b8,0b8,0b8,0b8,0b8
                  db  0b8,0b8,8a,8a,8a,8a,0b8,0b8
                  db  0b8,0b8,8a,8a,8a,8a,0b8,0b8
                  db  0b8,0b8,8a,8a,8a,8a,0b8,0b8
                  db  0b8,0b8,8a,8a,8a,8a,0b8,0b8
                  db  0b8,0b8,0b8,0b8,0b8,0b8,0b8,0b8
                  db  0b8,0b8,0b8,0b8,0b8,0b8,0b8,0b8
dim_sprite_obj    db   08, 08
data_sprite_obj   db  0b8,0b8,0b8,0b8,0b8,0b8,0b8,0b8
                  db  0b8,28,0b8,0b8,0b8,0b8,28,0b8
                  db  0b8,0b8,28,0b8,0b8,28,0b8,0b8
                  db  0b8,0b8,0b8,28,28,0b8,0b8,0b8
                  db  0b8,0b8,0b8,28,28,0b8,0b8,0b8
                  db  0b8,0b8,28,0b8,0b8,28,0b8,0b8
                  db  0b8,28,0b8,0b8,0b8,0b8,28,0b8
                  db  0b8,0b8,0b8,0b8,0b8,0b8,0b8,0b8
mapa              db   3e8 dup (0)

endm