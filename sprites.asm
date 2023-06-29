getSprites macro


dim_sprite_jug    db   08, 08
data_sprite_jug   db   5c, 5c, 5c, 04, 04, 04, 5c, 5c
                  db   5c, 5c, 5c, 54, 54, 5c, 5c, 5c
                  db   5c, 5c, 02, 02, 02, 02, 5c, 5c
                  db   5c, 54, 5c, 02, 02, 5c, 54, 5c
                  db   5c, 5c, 5c, 09, 09, 5c, 5c, 5c
                  db   5c, 5c, 5c, 09, 09, 5c, 5c, 5c
                  db   5c, 5c, 54, 5c, 5c, 54, 5c, 5c
                  db   5c, 00, 00, 5c, 5c, 00, 00, 5c
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
data_sprite_suelo db   5c, 5c, 5c, 5c, 5c, 5c, 5c, 5c
                  db   5c, 5c, 5c, 5c, 5c, 5c, 5c, 5c
                  db   5c, 5c, 5c, 5c, 5c, 5c, 5c, 5c
                  db   5c, 5c, 5c, 5c, 5c, 5c, 5c, 5c
                  db   5c, 5c, 5c, 5c, 5c, 5c, 5c, 5c
                  db   5c, 5c, 5c, 5c, 5c, 5c, 5c, 5c
                  db   5c, 5c, 5c, 5c, 5c, 5c, 5c, 5c
                  db   5c, 5c, 5c, 5c, 5c, 5c, 5c, 5c
dim_sprite_pared  db   08, 08
data_sprite_pared db   35, 35, 0f, 0f, 35, 35, 0f, 0f
                  db   35, 0f, 0f, 35, 35, 0f, 0f, 35
                  db   0f, 0f, 35, 35, 0f, 0f, 35, 35
                  db   0f, 35, 35, 0f, 0f, 35, 35, 0f
                  db   35, 35, 0f, 0f, 35, 35, 0f, 0f
                  db   35, 0f, 0f, 35, 35, 0f, 0f, 35
                  db   0f, 0f, 35, 35, 0f, 0f, 35, 35
                  db   0f, 35, 35, 0f, 0f, 35, 35, 0f
dim_sprite_caja   db   08, 08
data_sprite_caja  db  5c,5c,5c,5c,5c,5c,5c,5c
                  db  5c,5c,0b8,0b8,0b8,0b8,5c,5c
                  db  5c,0b8,8a,8a,8a,8a,0b8,5c
                  db  5c,0b8,8a,8a,8a,8a,0b8,5c
                  db  5c,0b8,8a,8a,8a,8a,0b8,5c
                  db  5c,0b8,8a,8a,8a,8a,0b8,5c
                  db  5c,5c,0b8,0b8,0b8,0b8,5c,5c
                  db  5c,5c,5c,5c,5c,5c,5c,5c
dim_sprite_obj    db   08, 08
data_sprite_obj   db  5c,5c,5c,5c,5c,5c,5c,5c
                  db  5c,28,5c,5c,5c,5c,28,5c
                  db  5c,5c,28,5c,5c,28,5c,5c
                  db  5c,5c,5c,28,28,5c,5c,5c
                  db  5c,5c,5c,28,28,5c,5c,5c
                  db  5c,5c,28,5c,5c,28,5c,5c
                  db  5c,28,5c,5c,5c,5c,28,5c
                  db  5c,5c,5c,5c,5c,5c,5c,5c
mapa              db   3e8 dup (0)

endm