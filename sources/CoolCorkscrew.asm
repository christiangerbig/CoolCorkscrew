; ###############################
; # Programm: CoolCorkscrew.asm #
; # Autor:    Christian Gerbig  #
; # Datum:    02.06.2024        #
; # Version:  1.2               #
; # CPU:      68020+            #
; # FASTMEM:  -                 #
; # Chipset:  AGA               #
; # OS:       3.0+              #
; ###############################

; V.1.0 Beta
; - Erstes Release

; V.1.1 Beta
; - Code optimiert
; - Text geändert

; V.1.2 Beta
; - Geschwindigkeit des Raumschiffs um 50% reduziert. Hier für wird eine separate
;   Sinus-Tabelle mit 512 Werten verwendet.
; - Sprite-Nutzung geändert, damit das Raumschiff auch am linken Rand ohne
;   Anzeigefehler dargestellt wird.
;   SPR0/1 Raumschiff
;   SRP2-7 Character-Scrolling

; V.1.3 Beta
; - Das Raumschiff bewegt sich jetzt von rechts nach links und wieder zurück
;   SPR0-5 Character-Scrolling
;   SPR0/1 (re-use) Raumschiff nach links
;   SPR2/3 (re-use) Raumschiff nach rechts

; V1.4 Beta
; - Mit Grass' RSE-Grafik.
; - Convert-Color-Table der Bar wird schon bei den Inits aufgerufen, damit schon
;   zu Beginn die Farbwerte der Bar richtig dargestellt werden.

; V.1.5 Beta
; - Mit Grass' überarbeitetem Logo ("C"-Version)

; V1.6 Beta
; - Mit Grass' Font
; - Mit angepassten Farbverläufen der Bars und des Scrolltexts

; V1.7 Beta
; - Mit Grass' Raumschiff

; V.1.8 Beta
; - Mit Grass´icon
; - WB-Start
; - WB-Fader

; V.1.9 Beta
; - Scrolltext geändert, damit er syncron zur Musik endet.

; V.1.0
; - Credits geändert
; - Code optimiert
; - Mouse-Handler: Out-Fader stoppen ggf. In-Fader
; - Mit Lunix' Icon
; - Spaceship-Animation: Jetzt wird der vom User ausgelöste Rechtsflug vom
;                        Scrolltext unterbrochen und die Raumschiff-Grafik
;                        wird nun im horizontal Blank geändert. Es werden
;                        nur noch SPR0 & SPR1 benutzt.
; - adf-Datei erstellt
; V1.1
; - Fader optimiert

; V.1.1
; Credits erneut geändert und luNix auf eigenen Wunsch wieder herausgenommen.
; Im Icon ab den Offset $3a und $3e die Werte $80000000 eingetragen, damit
; es keine fixe Position mehr hat
; überarbeitetete Include-Files integriert
; Move-Spaceship optimiert

; V.1.2
; Fader-Code optimiert


; PT 8xy-Befehl
; 800 Start intro
; 810 Increase x_radius_angle_step
; 820 Start calculate z_planes_step
; 830 Start scrolltext

; Ausführungszeit 68020: 277 Rasterzeilen

  SECTION code_and_variables,CODE

  MC68040


; ** Library-Includes V.3.x nachladen **
; --------------------------------------
  ;INCDIR  "OMA:include/"
  INCDIR "Daten:include3.5/"

  INCLUDE "dos/dos.i"
  INCLUDE "dos/dosextens.i"
  INCLUDE "libraries/dos_lib.i"

  INCLUDE "exec/exec.i"
  INCLUDE "exec/exec_lib.i"

  INCLUDE "graphics/GFXBase.i"
  INCLUDE "graphics/videocontrol.i"
  INCLUDE "graphics/graphics_lib.i"

  INCLUDE "intuition/intuition.i"
  INCLUDE "intuition/intuition_lib.i"

  INCLUDE "resources/cia_lib.i"

  INCLUDE "hardware/adkbits.i"
  INCLUDE "hardware/blit.i"
  INCLUDE "hardware/cia.i"
  INCLUDE "hardware/custom.i"
  INCLUDE "hardware/dmabits.i"
  INCLUDE "hardware/intbits.i"

  INCDIR "Daten:Asm-Sources.AGA/normsource-includes/"


; ** Konstanten **
; ----------------

  INCLUDE "equals.i"

requires_68030                       EQU FALSE  
requires_68040                       EQU FALSE
requires_68060                       EQU FALSE
requires_fast_memory                 EQU FALSE
requires_multiscan_monitor           EQU FALSE

workbench_start                      EQU TRUE
workbench_fade                       EQU TRUE
text_output                          EQU FALSE

pt_v3.0b
  IFD pt_v2.3a
    INCLUDE "music-tracker/pt2-equals.i"
  ENDC
  IFD pt_v3.0b
    INCLUDE "music-tracker/pt3-equals.i"
  ENDC
pt_ciatiming                         EQU TRUE
pt_usedfx                            EQU %1111110101011010
pt_usedefx                           EQU %0000110000000000
pt_finetune                          EQU FALSE
  IFD pt_v3.0b
pt_metronome                         EQU FALSE
  ENDC
pt_track_channel_volumes             EQU FALSE
pt_track_channel_periods             EQU FALSE
pt_music_fader                       EQU TRUE
pt_split_module                      EQU TRUE

hcs_quick_x_max_restart              EQU FALSE

scs_pipe_effect                      EQU TRUE
scs_center_bar                       EQU TRUE

DMABITS                              EQU DMAF_SPRITE+DMAF_BLITTER+DMAF_COPPER+DMAF_RASTER+DMAF_MASTER+DMAF_SETCLR

  IFEQ pt_ciatiming
INTENABITS                           EQU INTF_EXTER+INTF_INTEN+INTF_SETCLR
  ELSE
INTENABITS                           EQU INTF_VERTB+INTF_EXTER+INTF_INTEN+INTF_SETCLR
  ENDC

CIAAICRBITS                          EQU CIAICRF_SETCLR
  IFEQ pt_ciatiming
CIABICRBITS                          EQU CIAICRF_TA+CIAICRF_TB+CIAICRF_SETCLR
  ELSE
CIABICRBITS                          EQU CIAICRF_TB+CIAICRF_SETCLR
  ENDC

COPCONBITS                           EQU TRUE

pf1_x_size1                          EQU 0
pf1_y_size1                          EQU 0
pf1_depth1                           EQU 0
pf1_x_size2                          EQU 0
pf1_y_size2                          EQU 0
pf1_depth2                           EQU 0
pf1_x_size3                          EQU 0
pf1_y_size3                          EQU 0
pf1_depth3                           EQU 0
pf1_colors_number                    EQU 0

pf2_x_size1                          EQU 0
pf2_y_size1                          EQU 0
pf2_depth1                           EQU 0
pf2_x_size2                          EQU 0
pf2_y_size2                          EQU 0
pf2_depth2                           EQU 0
pf2_x_size3                          EQU 0
pf2_y_size3                          EQU 0
pf2_depth3                           EQU 0
pf2_colors_number                    EQU 0
pf_colors_number                     EQU pf1_colors_number+pf2_colors_number
pf_depth                             EQU pf1_depth3+pf2_depth3

extra_pf_number                      EQU 2
extra_pf1_x_size                     EQU 320
extra_pf1_y_size                     EQU 30
extra_pf1_depth                      EQU 4
extra_pf2_x_size                     EQU 448
extra_pf2_y_size                     EQU (64*2)+2 ;Weil vert_scroll_speed = 2
extra_pf2_depth                      EQU 2

spr_number                           EQU 8
spr_x_size1                          EQU 64
spr_x_size2                          EQU 64
spr_depth                            EQU 2
spr_colors_number                    EQU 16
spr_odd_color_table_select           EQU 1
spr_even_color_table_select          EQU 1
vp2_spr_odd_color_table_select       EQU 2
vp2_spr_even_color_table_select      EQU 2
spr_used_number                      EQU 8
spr_swap_number                      EQU 8

  IFD pt_v2.3a
audio_memory_size                    EQU 0
  ENDC
  IFD pt_v3.0b
audio_memory_size                    EQU 2
  ENDC

disk_memory_size                     EQU 0

extra_memory_size                    EQU 0

chip_memory_size                     EQU 0

AGA_OS_Version                       EQU 39

  IFEQ pt_ciatiming
CIABCRABITS                          EQU CIACRBF_LOAD
  ENDC
CIABCRBBITS                          EQU CIACRBF_LOAD+CIACRBF_RUNMODE ;Oneshot mode
CIAA_TA_value                        EQU 0
CIAA_TB_value                        EQU 0
  IFEQ pt_ciatiming
CIAB_TA_value                        EQU 14187 ;= 0.709379 MHz * [20000 µs = 50 Hz duration for one frame on a PAL machine]
;CIAB_TA_value                        EQU 14318 ;= 0.715909 MHz * [20000 µs = 50 Hz duration for one frame on a NTSC machine]
  ELSE
CIAB_TA_value                        EQU 0
  ENDC
CIAB_TB_value                        EQU 362 ;= 0.709379 MHz * [511.43 µs = Lowest note period C1 with Tuning=-8 * 2 / PAL clock constant = 907*2/3546895 ticks per second]
                                             ;= 0.715909 MHz * [506.76 µs = Lowest note period C1 with Tuning=-8 * 2 / NTSC clock constant = 907*2/3579545 ticks per second]
CIAA_TA_continuous                   EQU FALSE
CIAA_TB_continuous                   EQU FALSE
  IFEQ pt_ciatiming
CIAB_TA_continuous                   EQU TRUE
  ELSE
CIAB_TA_continuous                   EQU FALSE
  ENDC
CIAB_TB_continuous                   EQU FALSE

beam_position                        EQU $133 ;Weil der Volume-Fader aktiviert ist und sich durch den mulu-Befehl die Ausführungszeit der Replay-Routine erhöht.

MINROW                               EQU VSTART_256_lines

display_window_HSTART                EQU HSTART_320_pixel
display_window_VSTART                EQU MINROW
DIWSTRTBITS                          EQU ((display_window_VSTART&$ff)*DIWSTRTF_V0)+(display_window_HSTART&$ff)
display_window_HSTOP                 EQU HSTOP_320_pixel
display_window_VSTOP                 EQU VSTOP_256_lines
DIWSTOPBITS                          EQU ((display_window_VSTOP&$ff)*DIWSTOPF_V0)+(display_window_HSTOP&$ff)

spr_pixel_per_datafetch              EQU 64 ;4x

; **** Vertical-Blank 1 ****
vb1_lines_number                     EQU (192-extra_pf1_y_size)/2

vb1_VSTART                           EQU MINROW
vb1_VSTOP                            EQU MINROW+vb1_lines_number

; **** Viewport 1 ****
vp1_pixel_per_line                   EQU 320
vp1_visible_pixels_number            EQU 320
vp1_visible_lines_number             EQU 30

vp1_VSTART                           EQU MINROW+((192-vp1_visible_lines_number)/2)
vp1_VSTOP                            EQU vp1_VSTART+vp1_visible_lines_number

vp1_pf_pixel_per_datafetch           EQU 64 ;4x
vp1_DDFSTRTBITS                      EQU DDFSTART_320_pixel
vp1_DDFSTOPBITS                      EQU DDFSTOP_320_pixel_4x

vp1_pf1_colors_number                EQU 16

; **** Vertical-Blank 2 ****
vb2_lines_number                     EQU (192-extra_pf1_y_size)/2

vb2_VSTART                           EQU vp1_VSTOP
vb2_VSTOP                            EQU vp1_VSTOP+vb2_lines_number

; **** Viewport 2 ****
vp2_pixel_per_line                   EQU 320
vp2_visible_pixels_number            EQU 320
vp2_visible_lines_number             EQU 64

vp2_VSTART                           EQU vb2_VSTOP
vp2_VSTOP                            EQU vp2_VSTART+vp2_visible_lines_number

vp2_pf_pixel_per_datafetch           EQU 64 ;4x
vp2_DDFSTRTBITS                      EQU DDFSTART_320_pixel
vp2_DDFSTOPBITS                      EQU DDFSTOP_320_pixel_4x

vp2_pf1_colors_number                EQU 4

; **** Viewport 1 ****
; ** Playfield 1 **
extra_pf1_plane_width                EQU extra_pf1_x_size/8
; **** Viewport 2 ****
; ** Playfield 1 **
extra_pf2_plane_width                EQU extra_pf2_x_size/8

; **** Viewport 1 ****
vp1_data_fetch_width                 EQU vp1_pixel_per_line/8
vp1_pf1_plane_moduli                 EQU (extra_pf1_plane_width*(extra_pf1_depth-1))+extra_pf1_plane_width-vp1_data_fetch_width
; **** Viewport 2 ****
vp2_data_fetch_width                 EQU vp2_pixel_per_line/8
vp2_pf1_plane_moduli                 EQU (extra_pf2_plane_width*(extra_pf2_depth-1))+extra_pf2_plane_width-vp2_data_fetch_width
vp2_pf2_plane_moduli                 EQU -((extra_pf2_plane_width*(extra_pf2_depth-1))+(extra_pf2_plane_width-vp2_data_fetch_width)+(2*vp2_data_fetch_width))

; **** View ****
BPLCON0BITS                          EQU BPLCON0F_ECSENA+((pf_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((pf_depth&$07)*BPLCON0F_BPU0) ;lores
BPLCON3BITS1                         EQU BPLCON3F_SPRES0
BPLCON3BITS2                         EQU BPLCON3BITS1+BPLCON3F_LOCT
BPLCON4BITS                          EQU (BPLCON4F_OSPRM4*spr_odd_color_table_select)+(BPLCON4F_ESPRM4*spr_even_color_table_select)
DIWHIGHBITS                          EQU (((display_window_HSTOP&$100)>>8)*DIWHIGHF_HSTOP8)+(((display_window_VSTOP&$700)>>8)*DIWHIGHF_VSTOP8)+(((display_window_HSTART&$100)>>8)*DIWHIGHF_HSTART8)+((display_window_VSTART&$700)>>8)
FMODEBITS                            EQU FMODEF_SPR32+FMODEF_SPAGEM
COLOR00BITS                          EQU $0e111d
COLOR00HIGHBITS                      EQU $011
COLOR00LOWBITS                       EQU $e1d
; **** Viewport 1 ****
vp1_BPLCON0BITS1                     EQU BPLCON0F_ECSENA+((extra_pf1_depth>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+((extra_pf1_depth&$07)*BPLCON0F_BPU0) ;lores
vp1_BPLCON0BITS2                     EQU BPLCON0F_ECSENA+BPLCON0F_COLOR ;blank
vp1_BPLCON1BITS                      EQU TRUE
vp1_BPLCON2BITS                      EQU TRUE
vp1_BPLCON3BITS1                     EQU BPLCON3BITS1
vp1_BPLCON3BITS2                     EQU vp1_BPLCON3BITS1+BPLCON3F_LOCT
vp1_BPLCON4BITS                      EQU BPLCON4BITS
vp1_FMODEBITS                        EQU FMODEBITS+FMODEF_BPL32+FMODEF_BPAGEM
vp1_COLOR00BITS                      EQU COLOR00BITS
; **** Viewport 2 ****
vp2_BPLCON0BITS1                     EQU BPLCON0F_ECSENA+(((extra_pf2_depth*2)>>3)*BPLCON0F_BPU3)+(BPLCON0F_COLOR)+BPLCON0F_DPF+(((extra_pf2_depth*2)&$07)*BPLCON0F_BPU0) ;lores, dual playfield
vp2_BPLCON0BITS2                     EQU BPLCON0F_ECSENA+BPLCON0F_COLOR ;blank
vp2_BPLCON1BITS                      EQU TRUE
vp2_BPLCON2BITS                      EQU BPLCON2F_PF2P2
vp2_BPLCON3BITS1                     EQU BPLCON3BITS1+BPLCON3F_PF2OF1
vp2_BPLCON3BITS2                     EQU vp2_BPLCON3BITS1+BPLCON3F_LOCT
vp2_BPLCON4BITS                      EQU (BPLCON4F_OSPRM4*vp2_spr_odd_color_table_select)+(BPLCON4F_ESPRM4*vp2_spr_even_color_table_select)
vp2_FMODEBITS                        EQU FMODEBITS+FMODEF_BPL32+FMODEF_BPAGEM
vp2_COLOR00BITS                      EQU COLOR00BITS

cl2_display_x_size                   EQU 320
cl2_display_width                    EQU cl2_display_x_size/8
cl2_display_y_size                   EQU vp1_visible_lines_number
; **** Vertical Blank  1 ****
cl2_vb1_HSTART                       EQU display_window_HSTART-(1*CMOVE_slot_period)
cl2_vb1_VSTART                       EQU vb1_VSTART
; **** Viewport 1 ****
cl2_vp1_HSTART                       EQU display_window_HSTART+(1*CMOVE_slot_period)
cl2_vp1_VSTART                       EQU vp1_VSTART
; **** Vertical-Blank 2 ****
cl2_vb2_HSTART                       EQU display_window_HSTART-(1*CMOVE_slot_period)
cl2_vb2_VSTART                       EQU vb2_VSTART
; **** Viewport 2 ****
cl2_vp2_HSTART                       EQU $00
cl2_vp2_VSTART                       EQU vp2_VSTART
; **** Copper-Interrupt ****
cl2_HSTART                           EQU $00
cl2_VSTART                           EQU beam_position&$ff

sine_table_length                    EQU 256
sine_table_length2                   EQU 512

; **** Background-Image ****
bg_image_x_size                      EQU 256
bg_image_plane_width                 EQU bg_image_x_size/8
bg_image_y_size                      EQU 30
bg_image_depth                       EQU 4
bg_image_x_position                  EQU 16
bg_image_y_position                  EQU 0

; **** PT-Replay ****
pt_fade_out_delay                    EQU 2 ;Ticks

; **** Horiz-Scaling-Image ****
hsi_shift_values_number              EQU 32
hsi_lines_number                     EQU bg_image_y_size
hsi_x_radius                         EQU 8
hsi_x_radius_angle_speed             EQU 5
hsi_x_angle_step                     EQU 4

; **** Horiz-Characterscrolling ****
hcs_image_x_size                     EQU 16
hcs_image_plane_width                EQU hcs_image_x_size/8
hcs_image_y_size                     EQU 15
hcs_image_depth                      EQU 4

hcs_used_sprites_number              EQU 6
hcs_reused_sprites_number            EQU 192/(hcs_image_y_size+1)*(hcs_used_sprites_number/2)

  IFEQ hcs_quick_x_max_restart
hcs_random_x_max                     EQU (512*4)-1
hcs_x_min                            EQU 0
hcs_x_max                            EQU hcs_random_x_max
  ELSE
hcs_random_x_max                     EQU (display_window_HSTOP-display_window_HSTART)*4
hcs_x_min                            EQU (display_window_HSTART-hcs_image_x_size)*4
hcs_x_max                            EQU display_window_HSTOP*4
hcs_sprite_x_restart                 EQU ((display_window_HSTOP-display_window_HSTART)+hcs_image_x_size)*4
  ENDC

hcs_planes_number                    EQU 3

hcs_last_plane_x_speed_max           EQU 9
hcs_last_plane_x_speed_angle_speed   EQU 1

hcs_planes_x_step_min                EQU 1
hcs_planes_x_step_max                EQU 4
hcs_planes_x_step_angle_speed        EQU 1

hcs_objects_per_sprite_number        EQU hcs_reused_sprites_number/(hcs_used_sprites_number/2)
hcs_objects_number                   EQU hcs_objects_per_sprite_number*(hcs_used_sprites_number/2)

; **** Single-Corkscrew-Scroll ****
scs_image_x_size                     EQU 320
scs_image_plane_width                EQU scs_image_x_size/8
scs_image_depth                      EQU 2
scs_origin_character_x_size          EQU 32
scs_origin_character_y_size          EQU 32

scs_text_character_x_size            EQU 32
scs_text_character_width             EQU scs_text_character_x_size/8
scs_text_character_y_size            EQU scs_origin_character_y_size
scs_text_character_depth             EQU scs_image_depth

scs_horiz_scroll_window_x_size       EQU vp2_visible_pixels_number+(scs_text_character_x_size*2)
scs_horiz_scroll_window_width        EQU scs_horiz_scroll_window_x_size/8
scs_horiz_scroll_window_y_size       EQU vp2_visible_lines_number*2
scs_horiz_scroll_window_depth        EQU scs_image_depth
scs_horiz_scroll_speed               EQU 2

scs_vert_scroll_window_x_size        EQU vp2_visible_pixels_number
scs_vert_scroll_window_width         EQU scs_vert_scroll_window_x_size/8
scs_vert_scroll_window_y_size        EQU vp2_visible_lines_number*2
scs_vert_scroll_window_depth         EQU scs_image_depth
scs_vert_scroll_speed1               EQU 2 ;Corkscrew-Effekt an
scs_vert_scroll_speed2               EQU 1 ;Corkscrew-Effekt aus

scs_text_character_x_shift_max       EQU scs_text_character_x_size
scs_text_character_x_restart         EQU vp2_visible_pixels_number+64
scs_text_character_y_restart         EQU 48
scs_text_character_vert_scroll_speed EQU 1
scs_text_characters_number           EQU scs_horiz_scroll_window_x_size/scs_text_character_x_size

scs_text_x_position                  EQU 48
scs_text_y_position                  EQU 0

scs_text_delay                       EQU (1*(scs_vert_scroll_window_y_size))+1 ;2 Umdrehungen der Schrift - Damit sich der Text syncron weiterbewegt wird die Höhe des Scrollfensters und nicht FPS genommen

  IFEQ scs_center_bar
scs_center_bar_height                EQU 10
  ENDC

; **** Scrolltext stauchen ****
scs_roller_y_radius                  EQU vp2_visible_lines_number/2
scs_roller_y_center                  EQU vp2_visible_lines_number/2
scs_roller_y_angle_step              EQU (sine_table_length/2)/vp2_visible_lines_number

; **** Pipe-Effekt ****
  IFEQ scs_pipe_effect
scs_pipe_shift_x_radius              EQU scs_roller_y_radius
scs_pipe_shift_x_center              EQU scs_roller_y_radius
  ENDC

; **** Sine-Bars ****
sb_bar_height                        EQU 10
sb_y_radius                          EQU ((vp2_visible_lines_number-sb_bar_height)/2)-1

; **** Sine-Bars 2.3.2 ****
sb232_bars_number                    EQU 8
sb232_y_center                       EQU (vp2_visible_lines_number-sb_bar_height)/2
sb232_y_radius_angle_speed           EQU 1
sb232_y_radius_angle_step            EQU 3
sb232_y_angle_speed                  EQU 2
sb232_y_distance                     EQU 14

; **** Sine-Bars 3.6 ****
sb36_bars_number                     EQU 4
sb36_y_center                        EQU (vp2_visible_lines_number-sb_bar_height)/2
sb36_y_angle_speed                   EQU 2
sb36_y_distance_min                  EQU 32
sb36_y_distance_max                  EQU sine_table_length/sb36_bars_number
sb36_y_distance_radius               EQU ((sb36_y_distance_max-sb36_y_distance_min)/2)
sb36_y_distance_center               EQU ((sb36_y_distance_max-sb36_y_distance_min)/2)+sb36_y_distance_min
sb36_y_distance_speed                EQU 1
sb36_y_distance_step1                EQU 1

; **** Move-Ship ****
ms_image_x_size                      EQU 64
ms_image_plane_width                 EQU ms_image_x_size/8
ms_image_y_size                      EQU 32
ms_image_depth                       EQU 4

ms_x_radius                          EQU 384+64
ms_x_center                          EQU 384+64

; **** Move-Ship-Left ****
msl_x_angle_speed                    EQU 1
msl_spaceship_y_position             EQU vp2_VSTART+((vp2_visible_lines_number-ms_image_y_size)/2)

; **** Move-Ship-Right ****
msr_x_angle_speed                    EQU 1
msr_spaceship_y_position             EQU vp2_VSTART+((vp2_visible_lines_number-ms_image_y_size)/2)

; **** Radius-Fader ****
rf_max_y_radius                      EQU sb_y_radius*2

; **** Radius-Fader-In ****
rfi_delay                            EQU 4
rfi_delay_speed                      EQU 1
rfi_speed                            EQU 1

; **** Radius-Fader-Out ****
rfo_delay                            EQU 3
rfo_delay_speed                      EQU 1
rfo_speed                            EQU 1

; **** Image-Fader ****
if_start_color                       EQU 1
if_color_table_offset                EQU 1
if_colors_number                     EQU vp1_pf1_colors_number-1

; **** Image-Fader-In ****
ifi_fader_speed_max                  EQU 4
ifi_fader_radius                     EQU ifi_fader_speed_max
ifi_fader_center                     EQU ifi_fader_speed_max+1
ifi_fader_angle_speed                EQU 2

; **** Image-Fader-Out ****
ifo_fader_speed_max                  EQU 3
ifo_fader_radius                     EQU ifo_fader_speed_max
ifo_fader_center                     EQU ifo_fader_speed_max+1
ifo_fader_angle_speed                EQU 1

; **** Sprite-Fader ****
sprf_start_color                     EQU 1
sprf_color_table_offset              EQU 1
sprf_colors_number                   EQU spr_colors_number-1

; **** Sprite-Fader-In ****
sprfi_fader_speed_max                EQU 2
sprfi_fader_radius                   EQU sprfi_fader_speed_max
sprfi_fader_center                   EQU sprfi_fader_speed_max+1
sprfi_fader_angle_speed              EQU 1

; **** Sprite-Fader-Out ****
sprfo_fader_speed_max                EQU 2
sprfo_fader_radius                   EQU sprfo_fader_speed_max
sprfo_fader_center                   EQU sprfo_fader_speed_max+1
sprfo_fader_angle_speed              EQU 1

; **** Bar-Fader ****
bf_color_table_offset                EQU 0
bf_colors_number                     EQU sb_bar_height

; **** Bar-Fader-In ****
bfi_fader_speed_max                  EQU 4
bfi_fader_radius                     EQU bfi_fader_speed_max
bfi_fader_center                     EQU bfi_fader_speed_max+1
bfi_fader_angle_speed                EQU 2

; **** Bar-Fader-Out ****
bfo_fader_speed_max                  EQU 3
bfo_fader_radius                     EQU bfo_fader_speed_max
bfo_fader_center                     EQU bfo_fader_speed_max+1
bfo_fader_angle_speed                EQU 1


extra_pf2_1_bitplane_x_offset        EQU 1*vp2_pf_pixel_per_datafetch
extra_pf2_1_bitplane_y_offset        EQU vp2_visible_lines_number
extra_pf2_2_bitplane_x_offset        EQU 1*vp2_pf_pixel_per_datafetch
extra_pf2_2_bitplane_y_offset        EQU vp2_visible_lines_number-1


; ## Makrobefehle ##
; ------------------

  INCLUDE "macros.i"


; ** Struktur, die alle Exception-Vektoren-Offsets enthält **
; -----------------------------------------------------------

  INCLUDE "except-vectors-offsets.i"


; ** Struktur, die alle Eigenschaften des Extra-Playfields enthält **
; -------------------------------------------------------------------

  INCLUDE "extra-pf-attributes-structure.i"


; ** Struktur, die alle Eigenschaften der Sprites enthält **
; ----------------------------------------------------------

  INCLUDE "sprite-attributes-structure.i"


; ** Struktur, die alle Registeroffsets der ersten Copperliste enthält **
; -----------------------------------------------------------------------
  RSRESET

cl1_begin        RS.B 0

  INCLUDE "copperlist1-offsets.i"

cl1_COPJMP2      RS.L 1

copperlist1_SIZE RS.B 0


; ** Struktur, die alle Registeroffsets der zweiten Copperliste enthält **
; ------------------------------------------------------------------------
  RSRESET

cl2_extension1      RS.B 0

cl2_ext1_WAIT       RS.L 1
cl2_ext1_BPL1DAT    RS.L 1

cl2_extension1_SIZE RS.B 0


  RSRESET

cl2_extension2         RS.B 0

cl2_ext2_DDFSTRT       RS.L 1
cl2_ext2_DDFSTOP       RS.L 1
cl2_ext2_BPLCON1       RS.L 1
cl2_ext2_BPLCON2       RS.L 1
cl2_ext2_BPLCON3_1     RS.L 1
cl2_ext2_BPL1MOD       RS.L 1
cl2_ext2_BPL2MOD       RS.L 1
cl2_ext2_BPLCON4       RS.L 1
cl2_ext2_FMODE         RS.L 1
cl2_ext2_COLOR00_high1 RS.L 1
cl2_ext2_COLOR01_high1 RS.L 1
cl2_ext2_COLOR02_high1 RS.L 1
cl2_ext2_COLOR03_high1 RS.L 1
cl2_ext2_COLOR04_high1 RS.L 1
cl2_ext2_COLOR05_high1 RS.L 1
cl2_ext2_COLOR06_high1 RS.L 1
cl2_ext2_COLOR07_high1 RS.L 1
cl2_ext2_COLOR08_high1 RS.L 1
cl2_ext2_COLOR09_high1 RS.L 1
cl2_ext2_COLOR10_high1 RS.L 1
cl2_ext2_COLOR11_high1 RS.L 1
cl2_ext2_COLOR12_high1 RS.L 1
cl2_ext2_COLOR13_high1 RS.L 1
cl2_ext2_COLOR14_high1 RS.L 1
cl2_ext2_COLOR15_high1 RS.L 1
cl2_ext2_BPLCON3_low1  RS.L 1
cl2_ext2_COLOR00_low1  RS.L 1
cl2_ext2_COLOR01_low1  RS.L 1
cl2_ext2_COLOR02_low1  RS.L 1
cl2_ext2_COLOR03_low1  RS.L 1
cl2_ext2_COLOR04_low1  RS.L 1
cl2_ext2_COLOR05_low1  RS.L 1
cl2_ext2_COLOR06_low1  RS.L 1
cl2_ext2_COLOR07_low1  RS.L 1
cl2_ext2_COLOR08_low1  RS.L 1
cl2_ext2_COLOR09_low1  RS.L 1
cl2_ext2_COLOR10_low1  RS.L 1
cl2_ext2_COLOR11_low1  RS.L 1
cl2_ext2_COLOR12_low1  RS.L 1
cl2_ext2_COLOR13_low1  RS.L 1
cl2_ext2_COLOR14_low1  RS.L 1
cl2_ext2_COLOR15_low1  RS.L 1
cl2_ext2_BPL1PTH       RS.L 1
cl2_ext2_BPL1PTL       RS.L 1
cl2_ext2_BPL2PTH       RS.L 1
cl2_ext2_BPL2PTL       RS.L 1
cl2_ext2_BPL3PTH       RS.L 1
cl2_ext2_BPL3PTL       RS.L 1
cl2_ext2_BPL4PTH       RS.L 1
cl2_ext2_BPL4PTL       RS.L 1

cl2_extension2_SIZE    RS.B 0


  RSRESET

cl2_extension3      RS.B 0

cl2_ext3_WAIT       RS.L 1
cl2_ext3_BPLCON1_1  RS.L 1
cl2_ext3_BPLCON1_2  RS.L 1
cl2_ext3_BPLCON1_3  RS.L 1
cl2_ext3_BPLCON1_4  RS.L 1
cl2_ext3_BPLCON1_5  RS.L 1
cl2_ext3_BPLCON1_6  RS.L 1
cl2_ext3_BPLCON1_7  RS.L 1
cl2_ext3_BPLCON1_8  RS.L 1
cl2_ext3_BPLCON1_9  RS.L 1
cl2_ext3_BPLCON1_10 RS.L 1
cl2_ext3_BPLCON1_11 RS.L 1
cl2_ext3_BPLCON1_12 RS.L 1
cl2_ext3_BPLCON1_13 RS.L 1
cl2_ext3_BPLCON1_14 RS.L 1
cl2_ext3_BPLCON1_15 RS.L 1
cl2_ext3_BPLCON1_16 RS.L 1
cl2_ext3_BPLCON1_17 RS.L 1
cl2_ext3_BPLCON1_18 RS.L 1
cl2_ext3_BPLCON1_19 RS.L 1
cl2_ext3_BPLCON1_20 RS.L 1
cl2_ext3_BPLCON1_21 RS.L 1
cl2_ext3_BPLCON1_22 RS.L 1
cl2_ext3_BPLCON1_23 RS.L 1
cl2_ext3_BPLCON1_24 RS.L 1
cl2_ext3_BPLCON1_25 RS.L 1
cl2_ext3_BPLCON1_26 RS.L 1
cl2_ext3_BPLCON1_27 RS.L 1
cl2_ext3_BPLCON1_28 RS.L 1
cl2_ext3_BPLCON1_29 RS.L 1
cl2_ext3_BPLCON1_30 RS.L 1
cl2_ext3_BPLCON1_31 RS.L 1
cl2_ext3_BPLCON1_32 RS.L 1
cl2_ext3_BPLCON1_33 RS.L 1
cl2_ext3_BPLCON1_34 RS.L 1
cl2_ext3_BPLCON1_35 RS.L 1
cl2_ext3_BPLCON1_36 RS.L 1
cl2_ext3_BPLCON1_37 RS.L 1
cl2_ext3_BPLCON1_38 RS.L 1
cl2_ext3_BPLCON1_39 RS.L 1
cl2_ext3_BPLCON1_40 RS.L 1

cl2_extension3_SIZE RS.B 0


  RSRESET

cl2_extension4      RS.B 0

cl2_ext4_WAIT       RS.L 1
cl2_ext4_BPL1DAT    RS.L 1

cl2_extension4_SIZE RS.B 0


  RSRESET

cl2_extension5         RS.B 0

cl2_ext5_DDFSTRT       RS.L 1
cl2_ext5_DDFSTOP       RS.L 1
cl2_ext5_BPLCON1       RS.L 1
cl2_ext5_BPLCON2       RS.L 1
cl2_ext5_BPLCON3_1     RS.L 1
cl2_ext5_BPL1MOD       RS.L 1
cl2_ext5_BPL2MOD       RS.L 1
cl2_ext5_BPLCON4       RS.L 1
cl2_ext5_FMODE         RS.L 1
cl2_ext5_COLOR00_high1 RS.L 1
cl2_ext5_COLOR04_high1 RS.L 1
cl2_ext5_BPLCON3_low1  RS.L 1
cl2_ext5_COLOR00_low1  RS.L 1
cl2_ext5_COLOR04_low1  RS.L 1
cl2_ext5_BPL1PTH       RS.L 1
cl2_ext5_BPL1PTL       RS.L 1
cl2_ext5_BPL2PTH       RS.L 1
cl2_ext5_BPL2PTL       RS.L 1
cl2_ext5_BPL3PTH       RS.L 1
cl2_ext5_BPL3PTL       RS.L 1
cl2_ext5_BPL4PTH       RS.L 1
cl2_ext5_BPL4PTL       RS.L 1

cl2_extension5_SIZE    RS.B 0


  RSRESET

cl2_extension6        RS.B 0

cl2_ext6_WAIT         RS.L 1
  IFEQ scs_pipe_effect
cl2_ext6_BPLCON1      RS.L 1
  ENDC
cl2_ext6_BPLCON3_1    RS.L 1
cl2_ext6_BPL1MOD      RS.L 1
cl2_ext6_BPL2MOD      RS.L 1
  IFEQ scs_center_bar
cl2_ext6_COLOR00_high RS.L 1
  ENDC
cl2_ext6_COLOR01_high RS.L 1
cl2_ext6_COLOR02_high RS.L 1
cl2_ext6_COLOR05_high RS.L 1
cl2_ext6_COLOR06_high RS.L 1
cl2_ext6_BPLCON3_2    RS.L 1
  IFEQ scs_center_bar
cl2_ext6_COLOR00_low  RS.L 1
  ENDC
cl2_ext6_COLOR01_low  RS.L 1
cl2_ext6_COLOR02_low  RS.L 1
cl2_ext6_COLOR05_low  RS.L 1
cl2_ext6_COLOR06_low  RS.L 1
cl2_ext6_NOOP         RS.L 1

cl2_extension6_SIZE   RS.B 0


   RSRESET

cl2_begin            RS.B 0
; **** Vertical-Blank 1 ****
cl2_extension1_entry RS.B cl2_extension1_SIZE*vb1_lines_number
; **** Viewport 1 ****
cl2_extension2_entry RS.B cl2_extension2_SIZE
cl2_WAIT1            RS.L 1
cl2_BPLCON0_1        RS.L 1
cl2_extension3_entry RS.B cl2_extension3_SIZE*hsi_lines_number
cl2_WAIT2            RS.L 1
cl2_BPLCON0_2        RS.L 1
; **** Vertical-Blank 2 ****
cl2_extension4_entry RS.B cl2_extension4_SIZE*vb2_lines_number
; **** Viewport 2 ****
cl2_extension5_entry RS.B cl2_extension5_SIZE
cl2_WAIT3            RS.L 1
cl2_BPLCON0_3        RS.L 1
cl2_extension6_entry RS.B cl2_extension6_SIZE*vp2_visible_lines_number
; **** Copper-Interrupt ****
cl2_WAIT5            RS.L 1
cl2_INTREQ           RS.L 1

cl2_end              RS.L 1

copperlist2_SIZE     RS.B 0


; ** Konstanten für die Größe der Copperlisten **
; -----------------------------------------------
cl1_size1          EQU 0
cl1_size2          EQU 0
cl1_size3          EQU copperlist1_SIZE

cl2_size1          EQU 0
cl2_size2          EQU copperlist2_SIZE
cl2_size3          EQU copperlist2_SIZE


; ** Sprite0-Zusatzstruktur **
; ----------------------------
  RSRESET

spr0_extension1       RS.B 0

spr0_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr0_ext1_planedata   RS.L 1*(spr_pixel_per_datafetch/16)*hcs_image_y_size

spr0_extension1_SIZE  RS.B 0

  RSRESET

spr0_extension2       RS.B 0

spr0_ext2_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr0_ext2_planedata   RS.L 1*(spr_pixel_per_datafetch/16)*ms_image_y_size

spr0_extension2_SIZE  RS.B 0

; ** Sprite0-Hauptstruktur **
; ---------------------------
  RSRESET

spr0_begin            RS.B 0

spr0_extension1_entry RS.B spr0_extension1_SIZE*hcs_objects_per_sprite_number
spr0_extension2_entry RS.L spr0_extension2_SIZE

spr0_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite0_SIZE          RS.B 0

; ** Sprite1-Zusatzstruktur **
; ----------------------------
  RSRESET

spr1_extension1       RS.B 0

spr1_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr1_ext1_planedata   RS.L 1*(spr_pixel_per_datafetch/16)*hcs_image_y_size

spr1_extension1_SIZE  RS.B 0

  RSRESET

spr1_extension2       RS.B 0

spr1_ext2_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr1_ext2_planedata   RS.L 1*(spr_pixel_per_datafetch/16)*ms_image_y_size

spr1_extension2_SIZE  RS.B 0

; ** Sprite1-Hauptstruktur **
; ---------------------------
  RSRESET

spr1_begin            RS.B 0

spr1_extension1_entry RS.B spr1_extension1_SIZE*hcs_objects_per_sprite_number
spr1_extension2_entry RS.B spr1_extension2_SIZE

spr1_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite1_SIZE          RS.B 0

; ** Sprite2-Zusatzstruktur **
; ----------------------------
  RSRESET

spr2_extension1       RS.B 0

spr2_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr2_ext1_planedata   RS.L 1*(spr_pixel_per_datafetch/16)*hcs_image_y_size

spr2_extension1_SIZE  RS.B 0

; ** Sprite2-Hauptstruktur **
; ---------------------------
  RSRESET

spr2_begin            RS.B 0

spr2_extension1_entry RS.B spr2_extension1_SIZE*hcs_objects_per_sprite_number

spr2_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite2_SIZE          RS.B 0

; ** Sprite3-Zusatzstruktur **
; ----------------------------
  RSRESET

spr3_extension1       RS.B 0

spr3_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr3_ext1_planedata   RS.L 1*(spr_pixel_per_datafetch/16)*hcs_image_y_size

spr3_extension1_SIZE  RS.B 0

; ** Sprite3-Hauptstruktur **
; ---------------------------
  RSRESET

spr3_begin            RS.B 0

spr3_extension1_entry RS.B spr3_extension1_SIZE*hcs_objects_per_sprite_number

spr3_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite3_SIZE          RS.B 0

; ** Sprite4-Zusatzstruktur **
; ----------------------------
  RSRESET

spr4_extension1       RS.B 0

spr4_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr4_ext1_planedata   RS.L 1*(spr_pixel_per_datafetch/16)*hcs_image_y_size

spr4_extension1_SIZE  RS.B 0

; ** Sprite4-Hauptstruktur **
; ---------------------------
  RSRESET

spr4_begin            RS.B 0

spr4_extension1_entry RS.B spr4_extension1_SIZE*hcs_objects_per_sprite_number

spr4_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite4_SIZE          RS.B 0

; ** Sprite5-Zusatzstruktur **
; ----------------------------
  RSRESET

spr5_extension1       RS.B 0

spr5_ext1_header      RS.L 1*(spr_pixel_per_datafetch/16)
spr5_ext1_planedata   RS.L 1*(spr_pixel_per_datafetch/16)*hcs_image_y_size

spr5_extension1_SIZE  RS.B 0

; ** Sprite5-Hauptstruktur **
; ---------------------------
  RSRESET

spr5_begin            RS.B 0

spr5_extension1_entry RS.B spr5_extension1_SIZE*hcs_objects_per_sprite_number

spr5_end              RS.L 1*(spr_pixel_per_datafetch/16)

sprite5_SIZE          RS.B 0

; ** Sprite6-Hauptstruktur **
; ---------------------------
  RSRESET

spr6_begin       RS.B 0

spr6_end         RS.L 1*(spr_pixel_per_datafetch/16)

sprite6_SIZE     RS.B 0

; ** Sprite7-Hauptstruktur **
; ---------------------------
  RSRESET

spr7_begin       RS.B 0

spr7_end         RS.L 1*(spr_pixel_per_datafetch/16)

sprite7_SIZE     RS.B 0


; ** Konstanten für die Größe der Spritestrukturen **
; ---------------------------------------------------
spr0_x_size1     EQU spr_x_size1
spr0_y_size1     EQU sprite0_SIZE/(spr_x_size1/8)
spr1_x_size1     EQU spr_x_size1
spr1_y_size1     EQU sprite1_SIZE/(spr_x_size1/8)
spr2_x_size1     EQU spr_x_size1
spr2_y_size1     EQU sprite2_SIZE/(spr_x_size1/8)
spr3_x_size1     EQU spr_x_size1
spr3_y_size1     EQU sprite3_SIZE/(spr_x_size1/8)
spr4_x_size1     EQU spr_x_size1
spr4_y_size1     EQU sprite4_SIZE/(spr_x_size1/8)
spr5_x_size1     EQU spr_x_size1
spr5_y_size1     EQU sprite5_SIZE/(spr_x_size1/8)
spr6_x_size1     EQU spr_x_size1
spr6_y_size1     EQU sprite6_SIZE/(spr_x_size1/8)
spr7_x_size1     EQU spr_x_size1
spr7_y_size1     EQU sprite7_SIZE/(spr_x_size1/8)

spr0_x_size2     EQU spr_x_size2
spr0_y_size2     EQU sprite0_SIZE/(spr_x_size2/8)
spr1_x_size2     EQU spr_x_size2
spr1_y_size2     EQU sprite1_SIZE/(spr_x_size2/8)
spr2_x_size2     EQU spr_x_size2
spr2_y_size2     EQU sprite2_SIZE/(spr_x_size2/8)
spr3_x_size2     EQU spr_x_size2
spr3_y_size2     EQU sprite3_SIZE/(spr_x_size2/8)
spr4_x_size2     EQU spr_x_size2
spr4_y_size2     EQU sprite4_SIZE/(spr_x_size2/8)
spr5_x_size2     EQU spr_x_size2
spr5_y_size2     EQU sprite5_SIZE/(spr_x_size2/8)
spr6_x_size2     EQU spr_x_size2
spr6_y_size2     EQU sprite6_SIZE/(spr_x_size2/8)
spr7_x_size2     EQU spr_x_size2
spr7_y_size2     EQU sprite7_SIZE/(spr_x_size2/8)


; ** Struktur, die alle Variablenoffsets enthält **
; -------------------------------------------------

  INCLUDE "variables-offsets.i"

; ** Relative offsets for variables **
; ------------------------------------

; **** PT-Replay ****
  IFD pt_v2.3a
    INCLUDE "music-tracker/pt2-variables-offsets.i"
  ENDC
  IFD pt_v3.0b
    INCLUDE "music-tracker/pt3-variables-offsets.i"
  ENDC

pt_trigger_fx_state                    RS.W 1

; **** Horiz-Scaling-Image ****
hsi_x_radius_angle                     RS.W 1
hsi_variable_x_radius_angle_step       RS.W 1

; **** Horiz-Character-Scrolling ****
hcs_calculate_last_plane_x_speed_state RS.W 1
hcs_last_plane_x_speed_angle           RS.W 1
hcs_variable_last_plane_x_speed        RS.W 1

hcs_calculate_planes_x_step_state      RS.W 1
hcs_planes_x_step_angle                RS.W 1
hcs_variable_planes_x_step             RS.W 1

; **** Single-Corkscrew-Scroll ****
scs_image                              RS.L 1
scs_state                              RS.W 1
scs_text_table_start                   RS.W 1
scs_text_character_x_shift             RS.W 1
scs_text_character_y_offset            RS.W 1
scs_variable_vert_scroll_speed         RS.W 1
scs_text_delay_counter                 RS.W 1
scs_text_move_state                    RS.W 1

; **** Sine-Bars ****
sb_variable_y_radius                   RS.W 1

; **** Sine-Bars 2.3.2 ****
sb232_state                            RS.W 1
sb232_y_radius_angle                   RS.W 1
sb232_y_angle                          RS.W 1

; **** Sine-Bars 3.6 ****
sb36_state                             RS.W 1
sb36_y_angle                           RS.W 1
sb36_y_distance_angle                  RS.W 1

; **** Move-Spaceship-Left ****
msl_state                              RS.W 1
msl_x_angle                            RS.W 1

; **** Move-Spaceship-Right ****
msr_state                              RS.W 1
msr_x_angle                            RS.W 1

; **** Radius-Fader-In ****
rfi_state                              RS.W 1
rfi_delay_counter                      RS.W 1

; **** Radius-Fader-Out ****
rfo_state                              RS.W 1
rfo_delay_counter                      RS.W 1

; **** Image-Fader ****
if_colors_counter                      RS.W 1
if_copy_colors_state                   RS.W 1

; **** Image-Fader-In ****
ifi_state                              RS.W 1
ifi_fader_angle                        RS.W 1

; **** Image-Fader-Out ****
ifo_state                              RS.W 1
ifo_fader_angle                        RS.W 1

; **** Sprite-Fader ****
sprf_colors_counter                    RS.W 1
sprf_copy_colors_state                 RS.W 1

; **** Sprite-Fader-In ****
sprfi_state                            RS.W 1
sprfi_fader_angle                      RS.W 1

; **** Sprite-Fader-Out ****
sprfo_state                            RS.W 1
sprfo_fader_angle                      RS.W 1

; **** Bar-Fader ****
bf_colors_counter                      RS.W 1
bf_convert_colors_state                RS.W 1

; **** Bar-Fader-In ****
bfi_state                              RS.W 1
bfi_fader_angle                        RS.W 1

; **** Bar-Fader-Out ****
bfo_state                              RS.W 1
bfo_fader_angle                        RS.W 1

; **** Main ****
fx_state                               RS.W 1
quit_state                             RS.W 1

variables_SIZE                         RS.B 0


; **** PT-Replay ****
; ** PT-Song-Structure **
; -----------------------
  INCLUDE "music-tracker/pt-song-structure.i"

; ** Temporary channel structure **
; ---------------------------------
  INCLUDE "music-tracker/pt-temp-channel-structure.i"


; ## Beginn des Initialisierungsprogramms ##
; ------------------------------------------

  INCLUDE "sys-init.i"

; ** Eigene Variablen initialisieren **
; -------------------------------------
  CNOP 0,4
init_own_variables

; **** PT-Replay ****
  IFD pt_v2.3a
    PT2_INIT_VARIABLES
  ENDC
  IFD pt_v3.0b
    PT3_INIT_VARIABLES
  ENDC

  moveq   #TRUE,d0
  move.w  d0,pt_trigger_fx_state(a3)

; **** Horiz-Scaling-Image ****
  move.w  d0,hsi_x_radius_angle(a3) ;0 Grad
  move.w  d0,hsi_variable_x_radius_angle_step(a3) ;0 Grad

; **** Horiz-Character-Scrolling ****
  move.w  d0,hcs_calculate_last_plane_x_speed_state(a3)
  MOVEF.W sine_table_length/4,d2
  move.w  d2,hcs_last_plane_x_speed_angle(a3) :90 Grad
  move.w  d0,hcs_variable_last_plane_x_speed(a3)
  moveq   #FALSE,d1
  move.w  d1,hcs_calculate_planes_x_step_state(a3)
  move.w  d2,hcs_planes_x_step_angle(a3) ;90 Grad
  moveq   #hcs_planes_x_step_min,d2
  move.w  d2,hcs_variable_planes_x_step(a3)

; **** Single-Corkscrew-Scroll ****
  lea     scs_image_data,a0
  move.w  d1,scs_state(a3)
  move.l  a0,scs_image(a3)
  move.w  d0,scs_text_table_start(a3)
  move.w  d0,scs_text_character_x_shift(a3)
  move.w  #scs_text_character_y_restart*extra_pf2_plane_width*scs_vert_scroll_window_depth,scs_text_character_y_offset(a3)
  moveq   #scs_vert_scroll_speed2,d2
  move.w  d2,scs_variable_vert_scroll_speed(a3)
  move.w  d1,scs_text_delay_counter(a3) ;Zähler inaktiv
  move.w  d0,scs_text_move_state(a3)

; **** Sine-Bars ****
  move.w  d0,hcs_planes_x_step_angle(a3) ;0 Grad
  move.w  d0,sb_variable_y_radius(a3) :0 Grad

; **** Sine-Bars 2.3.2 ****
  move.w  d1,sb232_state(a3)
  move.w  d0,sb232_y_radius_angle(a3) ;0 Grad
  move.w  d0,sb232_y_angle(a3) ;0 Grad

; **** Sine-Bars 3.6 ****
  move.w  d1,sb36_state(a3)
  move.w  d0,sb36_y_angle(a3) ;0 Grad
  move.w  d0,sb36_y_distance_angle(a3) ;0 Grad

; **** Move-Spaceship ****
  move.w  d1,msl_state(a3)
  MOVEF.W sine_table_length2/4,d3
  move.w  d2,msl_x_angle(a3) ;90 Grad

  move.w  d1,msr_state(a3)
  move.w  d2,msr_x_angle(a3) ;90 Grad

; **** Radius-Fader-In ****
  move.w  d1,rfi_state(a3)
  move.w  d0,rfi_delay_counter(a3)

; **** Radius-Fader-Out *****
  move.w  d1,rfo_state(a3)
  move.w  d0,rfo_delay_counter(a3)

; **** Image-Fader ****
  move.w  d0,if_colors_counter(a3)
  move.w  d1,if_copy_colors_state(a3)

; **** Image-Fader-In ****
  move.w  d1,ifi_state(a3)
  MOVEF.W sine_table_length/4,d2
  move.w  d2,ifi_fader_angle(a3) ;90 Grad

; **** Image-Fader-Out ****
  move.w  d1,ifo_state(a3)
  move.w  d2,ifo_fader_angle(a3) ; 90 Grad

; **** Sprite-Fader ****
  move.w  d0,sprf_colors_counter(a3)
  move.w  d1,sprf_copy_colors_state(a3)

; **** Sprite-Fader-In ****
  move.w  d1,sprfi_state(a3)
  MOVEF.W sine_table_length/4,d2
  move.w  d2,sprfi_fader_angle(a3) ;90 Grad

; **** Sprite-Fader-Out ****
  move.w  d1,sprfo_state(a3)
  move.w  d2,sprfo_fader_angle(a3) ;90 Grad

; **** Bar-Fader ****
  move.w  d0,bf_colors_counter(a3)
  move.w  d1,bf_convert_colors_state(a3)

; **** Bar-Fader-In ****
  move.w  d1,bfi_state(a3)
  MOVEF.W sine_table_length/4,d2
  move.w  d2,bfi_fader_angle(a3) ;90 Grad

; **** Bar-Fader-Out ****
  move.w  d1,bfo_state(a3)
  move.w  d2,bfo_fader_angle(a3) ;90 Grad

; **** Main ****
  move.w  d1,fx_state(a3)
  move.w  d1,quit_state(a3)
  rts

; ** Alle Initialisierungsroutinen ausführen **
; ---------------------------------------------
  CNOP 0,4
init_all
  bsr.s   init_color_registers
  bsr.s   pt_DetectSysFrEQU
  bsr     init_CIA_timers
  bsr     pt_InitRegisters
  bsr     pt_InitAudTempStrucs
  bsr     pt_ExamineSongStruc
  IFEQ pt_finetune
    bsr     pt_InitFtuPeriodTableStarts
  ENDC
  bsr     bg_copy_image_to_bitplane
  bsr     hsi_init_shift_table
  bsr     scs_init_characters_offsets
  IFEQ scs_pipe_effect
    bsr     scs_init_x_shift_table
  ENDC
  bsr     bf_convert_color_table2
  bsr     init_sprites
  bsr     init_first_copperlist
  bra     init_second_copperlist


; ** Farbregister initialisieren **
; ---------------------------------
  CNOP 0,4
init_color_registers
  CPU_SELECT_COLORHI_BANK 1
  CPU_INIT_COLORHI COLOR00,16,vp2_spr_color_table

  CPU_SELECT_COLORLO_BANK 1
  CPU_INIT_COLORLO COLOR00,16,vp2_spr_color_table
  rts

; ** Detect system frequency NTSC/PAL **
; --------------------------------------
  PT_DETECT_SYS_FREQUENCY

; ** CIA-Timer initialisieren **
; ------------------------------
  CNOP 0,4
init_CIA_timers

; **** PT-Replay ****
  PT_INIT_TIMERS
  rts

; **** PT-Replay ****
; ** Audioregister initialisieren **
; ----------------------------------
   PT_INIT_REGISTERS

; ** Temporäre Audio-Kanal-Struktur initialisieren **
; ---------------------------------------------------
   PT_INIT_AUDIO_TEMP_STRUCTURES

; ** Höchstes Pattern ermitteln und Tabelle mit Zeigern auf Samples initialisieren **
; -----------------------------------------------------------------------------------
   PT_EXAMINE_SONG_STRUCTURE

  IFEQ pt_finetune
; ** FineTuning-Offset-Tabelle initialisieren **
; ----------------------------------------------
    PT_INIT_FINETUNING_PERIOD_TABLE_STARTS
  ENDC

; **** Background-Image ****
; ** Objekt ins Playfield kopieren **
; -----------------------------------
  COPY_IMAGE_TO_BITPLANE bg,bg_image_x_position,bg_image_y_position,extra_pf1

; **** Horiz-Scaling-Image ****
; ** Tabelle mit Shiftwerten initialisieren **
; --------------------------------------------
  CNOP 0,4
hsi_init_shift_table
  moveq   #TRUE,d0           ;1. Shiftwert
  lea     hsi_shift_table(pc),a0 ;Zeiger auf Tabelle mit Shiftwerten
  moveq   #hsi_shift_values_number-1,d7 ;Anzahl der Einträge
hsi_init_shift_table_loop
  move.b  d0,(a0)+           ;Shiftwert
  addq.w  #1*4,d0            ;erhöhen
  dbf     d7,hsi_init_shift_table_loop
  rts

; **** Single-Corkscrew-Scroll ****
; ** Offsets der Buchstaben im Characters-Pic berechnen **
; --------------------------------------------------------
  INIT_CHARACTERS_OFFSETS.W scs

; ** Shiftwerte für X-Shift berechnen **
; --------------------------------------
  IFEQ scs_pipe_effect
    CNOP 0,4
scs_init_x_shift_table
    moveq   #TRUE,d1           ;1. Y-Winkel
    moveq   #scs_pipe_shift_x_radius*2,d2
    MOVEF.L sine_table_length/2,d3 ;Länge der Tabelle (180 Grad)
    divu.w  #scs_roller_y_radius*2,d3 ;Schrittweite in Sinus-Tabelle berechnen
    lea     sine_table(pc),a0    ;Sinus-Tabelle
    lea     scs_pipe_shift_x_table(pc),a1 ;Tabelle mit X-Shift-Werten
    moveq   #(scs_roller_y_radius*2)-1,d7 ;Anzahl der Zeilen
scs_init_x_shift_table_loop
    move.w  2(a0,d1.w*4),d0    ;sin(w)
    muls.w  d2,d0              ;x'=(xr*sin(w))/2^15
    swap    d0
    move.w  d0,(a1)+           ;X-Shift-Wert x' retten
    add.w   d3,d1              ;nächster X-Winkel
    dbf     d7,scs_init_x_shift_table_loop
    rts
  ENDC

; ** Sprites initialisieren **
; ----------------------------
  CNOP 0,4
init_sprites
  bsr.s   spr_init_pointers_table
  bsr.s   hcs_init_xy_coordinates
  bsr     hcs_init_sprites_bitmaps
  bra     spr_copy_structures

; ** Tabelle mit Zeigern auf Sprites initialisieren **
; ----------------------------------------------------
  INIT_SPRITE_POINTERS_TABLE

; ** Sprite-Koordinaten initialisieren **
; ---------------------------------------
  CNOP 0,4
hcs_init_xy_coordinates
  movem.l a4-a5,-(a7)
  moveq   #TRUE,d3
  not.w   d3                 ;Maske = $0000ffff
  move.w  #hcs_random_x_max,d4
  lea     spr_pointers_construction(pc),a2 ;Zeiger auf Sprites
  lea     hcs_objects_x_coordinates(pc),a5 ;Zeiger auf X-Koords.
  moveq   #hcs_planes_number-1,d7 ;Anzahl der benutzten Sprites
hcs_init_xy_coordinates_loop1
  move.w  VHPOSR-DMACONR(a6),d5    ;f(x)
  move.l  (a2)+,a0           ;1. Sprite-Struktur
  move.l  (a2)+,a1           ;2. Sprite-Struktur
  move.w  #display_window_VSTART,a4 ;1. Y-Koordinate
  moveq   #hcs_objects_per_sprite_number-1,d6 ;Anzahl der Sterne pro Sprite
hcs_init_xy_coordinates_loop2
  mulu.w  VHPOSR-DMACONR(a6),d5    ;f(x)*a
  move.w  VHPOSR-DMACONR(a6),d1
  swap    d1
  move.b  _CIAA+CIATODLOW,d1
  lsl.w   #8,d1
  move.b  _CIAB+CIATODLOW,d1 ;b
  add.l   d1,d5              ;(f(x)*a)+b
  and.l   d3,d5              ;Nur Bits 0-15
  divu.w  d4,d5              ;f(x+1)=[(f(x)*a)+b]/mod
  swap    d5                 ;Rest der Division
  move.w  d5,d0              ;f(x+1) retten
  IFNE hcs_quick_x_max_restart
    add.w   #hcs_x_min,d0    ;X + linker Rand
  ENDC
  move.w  d0,(a5)+           ;X-Koord. retten
  move.w  a4,d1              ;Y
  bsr.s   hcs_init_sprite_header
  ADDF.W  spr2_extension1_SIZE,a0 ;n Bytes überspringen
  ADDF.W  spr3_extension1_SIZE,a1 ;n Bytes überspringen
  ADDF.W  hcs_image_y_size+1,a4 ;Y erhöhen
  dbf     d6,hcs_init_xy_coordinates_loop2
  dbf     d7,hcs_init_xy_coordinates_loop1
  movem.l (a7)+,a4-a5
  rts

; ** init_sprite_header-Routine **
; d0 ... X-Koordinate
; d1 ... Y-Koordinate
; a0 ... Zeiger auf erste Sprite-Struktur
; a1 ... Zeiger auf zweite Sprite-Struktur
  CNOP 0,4
hcs_init_sprite_header
  moveq   #hcs_image_y_size,d2 ;Höhe
  add.w   d1,d2              ;Höhe zu Y addieren
  SET_SPRITE_POSITION d0,d1,d2
  move.w  d1,(a0)            ;SPRxPOS
  move.w  d2,spr_pixel_per_datafetch/8(a0) ;SPRxCTL
  move.w  d1,(a1)            ;SPRxPOS
  tas     d2                 ;Attached-Bit setzen
  move.w  d2,spr_pixel_per_datafetch/8(a1) ;SPRxCTL
  rts

; ** Sprite-Bitplanes initalisieren **
; ------------------------------------
  CNOP 0,4
hcs_init_sprites_bitmaps
  movem.l a3-a6,-(a7)
  moveq   #(spr_pixel_per_datafetch/8)*2,d2
  lea     spr_pointers_construction(pc),a3 ;Zeiger auf Sprites
  lea     hcs_image_data,a4   ;Zeiger auf Image-Daten
  moveq   #hcs_planes_number-1,d7 ;Anzahl der Z-Ebenen
hcs_init_sprites_bitmaps_loop1
  move.l  (a3)+,a0           ;Zeiger auf 1. Sprite-Struktur
  move.l  (a3)+,a1           ;Zeiger auf 2. Sprite-Struktur
  moveq   #hcs_objects_per_sprite_number-1,d6 ;Anzahl der Character pro Sprite
hcs_init_sprites_bitmaps_loop2
  ADDF.W  (spr_pixel_per_datafetch/8)*2,a0 ;Header überspringen
  ADDF.W  (spr_pixel_per_datafetch/8)*2,a1
  move.l  a4,a2              ;Zeiger auf Image-Daten holen
  moveq   #hcs_image_y_size-1,d5   ;Anzahl der Zeilen
hcs_init_sprites_bitmaps_loop3
  move.w  (a2),(a0)          ;Plane0 gerades Sprite
  addq.w  #hcs_image_plane_width*hcs_planes_number,a2 ;nächste Zeile
  move.w  (a2),spr_pixel_per_datafetch/8(a0) ;Plane1 gerades Sprite
  add.l   d2,a0
  addq.w  #hcs_image_plane_width*hcs_planes_number,a2 ;nächste Zeile
  move.w  (a2),(a1)         ;Plane0 ungerades Sprite
  addq.w  #hcs_image_plane_width*hcs_planes_number,a2 ;nächste Zeile
  move.w  (a2),spr_pixel_per_datafetch/8(a1) ;Plane1 ungerades Sprite
  add.l   d2,a1
  addq.w  #hcs_image_plane_width*hcs_planes_number,a2 ;nächste Zeile
  dbf     d5,hcs_init_sprites_bitmaps_loop3
  dbf     d6,hcs_init_sprites_bitmaps_loop2
  addq.w  #hcs_image_plane_width,a4 ;nächster Character
  dbf     d7,hcs_init_sprites_bitmaps_loop1
  movem.l (a7)+,a3-a6
  rts

; ** Spritedaten kopieren **
; --------------------------
  COPY_SPRITE_STRUCTURES


; ** 1. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_first_copperlist
  move.l  cl1_display(a3),a0
  bsr.s   cl1_init_playfield_registers
  bsr     cl1_init_sprite_pointers
  bsr     cl1_init_color_registers
  COPMOVEQ TRUE,COPJMP2
  bra     cl1_set_sprite_pointers

  COP_INIT_PLAYFIELD_REGISTERS cl1,NOBITPLANESSPR

  COP_INIT_SPRITE_POINTERS cl1

  CNOP 0,4
cl1_init_color_registers
  COP_INIT_COLORHI COLOR16,16,spr_color_table

  COP_SELECT_COLORLO_BANK 0
  COP_INIT_COLORLO COLOR16,16,spr_color_table
  rts

  COP_SET_SPRITE_POINTERS cl1,display,spr_number

; ** 2. Copperliste initialisieren **
; -----------------------------------
  CNOP 0,4
init_second_copperlist
  move.l  cl2_construction2(a3),a0
; **** Vertical-Blank 1 ****
  bsr.s   cl2_vb1_init_BPLDAT_registers
; **** Viewport 1 ****
  bsr     cl2_vp1_init_playfield_registers
  bsr     cl2_vp1_init_color_registers
  bsr     cl2_vp1_init_bitplane_pointers
  COPWAIT 0,vp1_VSTART
  COPMOVEQ vp1_BPLCON0BITS1,BPLCON0
  bsr     cl2_init_BPLCON1_registers
  COPWAIT 0,vp1_VSTOP
  COPMOVEQ vp1_BPLCON0BITS2,BPLCON0
; **** Vertical-Blank 2 ****
  bsr     cl2_vb2_init_BPLDAT_registers
; **** Viewport 2 ****
  bsr     cl2_vp2_init_playfield_registers
  bsr     cl2_vp2_init_color_registers
  bsr     cl2_vp2_init_bitplane_pointers
  COPWAIT 0,vp2_VSTART
  COPMOVEQ vp2_BPLCON0BITS1,BPLCON0
  bsr     cl2_init_roller
; **** Copper-Interrupt ****
  bsr     cl2_init_copint
  COPLISTEND
  bsr     cl2_vp1_set_bitplane_pointers
  bsr     cl2_vp2_set_bitplane_pointers
  bsr     scs_set_vert_compression
  IFEQ scs_pipe_effect
    bsr     scs_set_color_gradients
    bsr     scs_set_pipe
  ELSE
    bsr     scs_set_color_gradients
  ENDC
  bsr     copy_second_copperlist
  bra     swap_second_copperlist

; **** Vertical Blank 1 ****
  CNOP 0,4
cl2_vb1_init_BPLDAT_registers
  move.l  #(((cl2_vb1_VSTART<<24)|(((cl2_vb1_HSTART/4)*2)<<16))|$10000)|$fffe,d0 ;WAIT-Befehl
  move.w  #BPL1DAT,d1
  moveq   #1,d2
  ror.l   #8,d2            ;$01000000 = Additionswert
  MOVEF.W vb1_lines_number-1,d7 ;Anzahl der Zeilen
cl2_vb1_init_BPLDAT_registers_loop
  move.l  d0,(a0)+         ;WAIT x,y
  add.l   d2,d0            ;nächste Zeile
  move.w  d1,(a0)          ;BPL1DAT
  addq.w  #4,a0
  dbf     d7,cl2_vb1_init_BPLDAT_registers_loop
  rts

; **** Viewport 1 ****
  COP_INIT_PLAYFIELD_REGISTERS cl2,,vp1

  CNOP 0,4
cl2_vp1_init_color_registers
  COP_INIT_COLORHI COLOR00,16,vp1_pf1_color_table

  COP_SELECT_COLORLO_BANK 0
  COP_INIT_COLORLO COLOR00,16,vp1_pf1_color_table
  rts

  CNOP 0,4
cl2_vp1_init_bitplane_pointers
  MOVEF.W BPL1PTH,d0
  moveq   #(extra_pf1_depth*2)-1,d7 ;Anzahl der Bitplanes
cl2_vp1_init_bitplane_pointers_loop
  move.w  d0,(a0)            ;BPLxPTH/L
  addq.w  #2,d0              ;nächstes Register
  addq.w  #4,a0              ;nächster Eintrag in CL
  dbf     d7,cl2_vp1_init_bitplane_pointers_loop
  rts

  CNOP 0,4
cl2_vp1_set_bitplane_pointers
  move.l  cl2_construction2(a3),a0 
  ADDF.W  cl2_extension2_entry+cl2_ext2_BPL1PTH+2,a0
  move.l  extra_pf1(a3),a1    ;Zeiger auf erste Plane
  moveq   #extra_pf1_depth-1,d7 ;Anzahl der Bitplanes
cl2_vp1_set_bitplane_pointers_loop
  move.w  (a1)+,(a0)         ;High-Wert
  addq.w  #8,a0              ;nächter Playfieldzeiger
  move.w  (a1)+,4-8(a0)      ;Low-Wert
  dbf     d7,cl2_vp1_set_bitplane_pointers_loop
  rts

  COP_INIT_BPLCON1_CHUNKY_SCREEN cl2,cl2_vp1_HSTART,cl2_vp1_VSTART,cl2_display_x_size,vp1_visible_lines_number,vp1_BPLCON1BITS

; **** Vertical-Blank 2 ****
  CNOP 0,4
cl2_vb2_init_BPLDAT_registers
  move.l  #(((cl2_vb2_VSTART<<24)|(((cl2_vb2_HSTART/4)*2)<<16))|$10000)|$fffe,d0 ;WAIT-Befehl
  move.w  #BPL1DAT,d1
  moveq   #1,d2
  ror.l   #8,d2            ;$01000000 = Additionswert
  MOVEF.W vb2_lines_number-1,d7 ;Anzahl der Zeilen
cl2_vb2_init_BPLDAT_registers_loop
  move.l  d0,(a0)+         ;WAIT x,y
  add.l   d2,d0            ;nächste Zeile
  move.w  d1,(a0)          ;BPL1DAT
  addq.w  #4,a0
  dbf     d7,cl2_vb2_init_BPLDAT_registers_loop
  rts

; **** Viewport 2 ****
  COP_INIT_PLAYFIELD_REGISTERS cl2,,vp2

  CNOP 0,4
cl2_vp2_init_color_registers
  COP_INIT_COLORHI COLOR00,1,vp2_pf1_color_table
  COP_INIT_COLORHI COLOR04,1,vp2_pf2_color_table

  COP_SELECT_COLORLO_BANK 0
  COP_INIT_COLORLO COLOR00,1,vp2_pf1_color_table
  COP_INIT_COLORLO COLOR04,1,vp2_pf2_color_table
  rts

  CNOP 0,4
cl2_vp2_init_bitplane_pointers
  MOVEF.W BPL1PTH,d0
  moveq   #(extra_pf2_depth*2*2)-1,d7 ;Anzahl der Bitplanes
cl2_vp2_init_bitplane_pointers_loop
  move.w  d0,(a0)            ;BPLxPTH/L
  addq.w  #2,d0              ;nächstes Register
  addq.w  #4,a0              ;nächster Eintrag in CL
  dbf     d7,cl2_vp2_init_bitplane_pointers_loop
  rts

  CNOP 0,4
cl2_init_roller
  movem.l a4-a6,-(a7)
  move.l  #(((cl2_vp2_VSTART<<24)|(((cl2_vp2_HSTART/4)*2)<<16))|$10000)|$fffe,d0 ;WAIT-Befehl
  move.l  #(BPLCON3<<16)+vp2_BPLCON3BITS1,d1 ;Low-RGB-Werte
  move.l  #COLOR01<<16,d2
  move.l  #(BPLCON3<<16)+vp2_BPLCON3BITS2,d3 ;Low-RGB-Werte
  move.l  #COLOR02<<16,d4
  move.l  #COLOR05<<16,d5
  moveq   #1,d6
  ror.l   #8,d6              ;$01000000 Additionswert
  move.l  #(BPL1MOD<<16)|((-extra_pf2_plane_width+(extra_pf2_plane_width-vp2_data_fetch_width))&$ffff),a1
  move.l  #(BPL2MOD<<16)|((-extra_pf2_plane_width+(extra_pf2_plane_width-vp2_data_fetch_width))&$ffff),a2
  IFEQ scs_pipe_effect
    move.l  #BPLCON1<<16,a4
  ENDC
  IFEQ scs_center_bar
    move.w  #COLOR00,a5
  ENDC
  move.l  #COLOR06<<16,a6
  moveq   #vp2_visible_lines_number-1,d7 ;Anzahl der Zeilen
cl2_init_roller_loop
  move.l  d0,(a0)+           ;WAIT x,y
  IFEQ scs_pipe_effect
    move.l  a4,(a0)+         ;BPLCON1
  ENDC
  move.l  d1,(a0)+           ;BPLCON3 High-Werte
  move.l  a1,(a0)+           ;BPL1MOD
  move.l  a2,(a0)+           ;BPL2MOD
  IFEQ scs_center_bar
    move.w  a5,(a0)+         ;COLOR00
    move.w  #COLOR00HIGHBITS,(a0)+
  ENDC
  move.l  d2,(a0)+           ;COLOR01
  move.l  d4,(a0)+           ;COLOR02
  move.l  d5,(a0)+           ;COLOR05
  move.l  a6,(a0)+           ;COLOR06
  move.l  d3,(a0)+           ;BPLCON3 Low-Werte
  IFEQ scs_center_bar
    move.w  a5,(a0)+         ;COLOR00
    move.w  #COLOR00LOWBITS,(a0)+
  ENDC
  move.l  d2,(a0)+           ;COLOR01
  move.l  d4,(a0)+           ;COLOR02
  move.l  d5,(a0)+           ;COLOR05
  move.l  a6,(a0)+           ;COLOR06
  cmp.l   #(((cl_y_wrap<<24)|(((cl2_vp2_HSTART/4)*2)<<16))|$10000)|$fffe,d0 ;Rasterzeile $ff erreicht ?
  bne.s   no_patch_copperlist2 ;Nein -> verzweige
patch_copperlist2
  COPWAIT cl_x_wrap,cl_y_wrap ;Copperliste patchen
  bra.s   cl2_init_roller_skip
  CNOP 0,4
no_patch_copperlist2
  COPMOVEQ TRUE,NOOP
cl2_init_roller_skip
  add.l   d6,d0              ;nächste Zeile
  dbf     d7,cl2_init_roller_loop
  movem.l (a7)+,a4-a6
  rts

; **** Copper-Interrupt ****
  COP_INIT_COPINT cl2,cl2_HSTART,cl2_VSTART

  CNOP 0,4
cl2_vp2_set_bitplane_pointers

; ** Zeiger auf Playfield 1 eintragen **
  MOVEF.L (extra_pf2_1_bitplane_x_offset/8)+(extra_pf2_1_bitplane_y_offset*extra_pf2_plane_width*extra_pf2_depth),d1 ;1. Hälfte
  move.l  cl2_construction2(a3),a0
  move.l  extra_pf2(a3),a2   ;Zeiger auf erste Plane
  lea     cl2_extension5_entry+cl2_ext5_BPL2PTH+2(a0),a1
  ADDF.W  cl2_extension5_entry+cl2_ext5_BPL1PTH+2,a0
  moveq   #extra_pf2_depth-1,d7 ;Anzahl der Bitplanes
cl2_vp2_set_bitplane_pointers_loop1
  move.l  (a2)+,d0           ;Bitplaneadresse holen
  add.l   d1,d0
  move.w  d0,4(a0)           ;BPLxPTL
  swap    d0                 ;High
  move.w  d0,(a0)            ;BPLxPTH
  ADDF.W  16,a0              ;übernächster Playfieldzeiger
  dbf     d7,cl2_vp2_set_bitplane_pointers_loop1

; ** Zeiger auf Playfield 2 eintragen **
  MOVEF.L (extra_pf2_2_bitplane_x_offset/8)+(extra_pf2_2_bitplane_y_offset*extra_pf2_plane_width*extra_pf2_depth),d1 ;2. Hälfte
  move.l  extra_pf2(a3),a2   ;Zeiger auf erste Plane
  moveq   #extra_pf2_depth-1,d7 ;Anzahl der Bitplanes
cl2_vp2_set_bitplane_pointers_loop2
  move.l  (a2)+,d0           ;Bitplaneadresse holen
  add.l   d1,d0
  move.w  d0,4(a1)           ;BPLxPTL
  swap    d0                 ;High
  move.w  d0,(a1)            ;BPLxPTH
  ADDF.W  16,a1              ;übernächster Playfieldzeiger
  dbf     d7,cl2_vp2_set_bitplane_pointers_loop2
  rts

  CNOP 0,4
scs_set_vert_compression
  MOVEF.W  sine_table_length/4,d1 ;erster Y-Winkel bei 90 Grad
  moveq   #scs_roller_y_radius*2,d3 ;Y-Radius
  moveq   #scs_roller_y_center,d4 ;Y-Mittelpunkt
  MOVEF.W (sine_table_length/4)*3,d5 ;270 Grad
  moveq   #cl2_extension6_SIZE,d6
  lea     sine_table(pc),a0    ;Sinus-Tabelle
  move.l  cl2_construction2(a3),a1
  ADDF.W  cl2_extension6_entry,a1 
  moveq   #extra_pf2_plane_width*extra_pf2_depth,d7
scs_set_vert_compression_loop
  move.w  2(a0,d1.w*4),d0    ;sin(w)
  muls.w  d3,d0              ;yr*sin(w)
  swap    d0                 ;y'=(yr*sin(w))/2^15
  add.w   d4,d0              ;y' + Y-Mittelpunkt
  mulu.w  d6,d0              ;Y-Offset in CL
  add.w   d7,cl2_ext6_BPL1MOD+2(a1,d0.l) ;BPL1MOD
  addq.w  #scs_roller_y_angle_step,d1 ;nächster Y-Winkel
  sub.w   d7,cl2_ext6_BPL2MOD+2(a1,d0.l) ;BPL2MOD
  cmp.w   d5,d1              ;Tabellenende 270 Grad ?
  ble.s   scs_set_vert_compression_loop ;Nein -> verzweige
  rts

  CNOP 0,4
scs_set_color_gradients
  movem.l a4-a5,-(a7)
  MOVEF.W COLOR00HIGHBITS,d2
  MOVEF.W COLOR00LOWBITS,d3
  lea     scs_color_gradient_front(pc),a0 ;Zeiger auf Farbtabelle
  lea     scs_color_gradient_back(pc),a1
  move.l  cl2_construction2(a3),a2 
  ADDF.W  cl2_extension6_entry+cl2_ext6_COLOR00_high+2,a2
  lea     scs_color_gradient_outline(pc),a4
  move.w  #cl2_extension6_SIZE,a5
  moveq   #vp2_visible_lines_number-1,d7 ;Anzahl der Farbwerte
scs_set_color_gradients_loop
  move.w  d2,(a2)            ;COLOR00 ;High-Bits
  move.w  d3,cl2_ext6_COLOR00_low-cl2_ext6_COLOR00_high(a2) ;COLOR00 ;Low-Bits
  move.w  (a0)+,cl2_ext6_COLOR01_high-cl2_ext6_COLOR00_high(a2) ;COLOR01 High-Bits
  move.w  (a0)+,cl2_ext6_COLOR01_low-cl2_ext6_COLOR00_high(a2) ;COLOR01 Low-Bits
  move.w  (a1)+,cl2_ext6_COLOR05_high-cl2_ext6_COLOR00_high(a2) ;COLOR05 High-Bits
  move.w  (a1)+,cl2_ext6_COLOR05_low-cl2_ext6_COLOR00_high(a2) ;COLOR05 Low-Bits
  move.l  (a4)+,d0
  move.w  d0,cl2_ext6_COLOR02_low-cl2_ext6_COLOR00_high(a2) ;COLOR02 Low-Bits
  move.w  d0,cl2_ext6_COLOR06_low-cl2_ext6_COLOR00_high(a2) ;COLOR06 Low-Bits
  swap    d0                 ;High-Bits
  move.w  d0,cl2_ext6_COLOR02_high-cl2_ext6_COLOR00_high(a2) ;COLOR02 High-Bits
  add.l   a5,a2              ;nächste Zeile
  move.w  d0,(cl2_ext6_COLOR06_high-cl2_ext6_COLOR00_high)-cl2_extension6_SIZE(a2) ;COLOR06 High-Bits
  dbf     d7,scs_set_color_gradients_loop
  movem.l (a7)+,a4-a5
  rts

  IFEQ scs_pipe_effect
    CNOP 0,4
scs_set_pipe
    moveq   #scs_pipe_shift_x_center,d2
    MOVEF.W $ff,d3             ;Scroll-Maske H0-H7
    lea     scs_pipe_shift_x_table(pc),a0 ;Tabelle mit X-Shift-Werten
    move.l  cl2_construction2(a3),a1 
    ADDF.W  cl2_extension6_entry+cl2_ext6_BPLCON1+2,a1
    move.w  #cl2_extension6_SIZE,a2
    moveq   #vp2_visible_lines_number-1,d7 ;Anzahl der Zeilen
scs_set_pipe_loop
    move.w  (a0)+,d0           ;Shiftwert x' lesen
    moveq   #scs_pipe_shift_x_center,d1
    sub.w   d0,d1              ;X-Mittelpunkt - x'
    add.w   d2,d0              ;X-Mittelpunkt + x'
    SEPARATE_PF_SOFTSCROLL_64PIXEL_LORES d1,d0,d3
    move.w  d1,(a1)            ;BPLCON1
    add.l   a2,a1              ;nächste Zeile in CL
    dbf     d7,scs_set_pipe_loop
    rts
  ENDC

  COPY_COPPERLIST cl2,2


; ** CIA-Timer starten **
; -----------------------

  INCLUDE "continuous-timers-start.i"


; ## Hauptprogramm ##
; -------------------
; a3 ... Basisadresse aller Variablen
; a4 ... CIA-A-Base
; a5 ... CIA-B-Base
; a6 ... DMACONR
  CNOP 0,4
main_routine
  bsr.s   no_sync_routines
  bra.s   beam_routines


; ## Routinen, die nicht mit der Bildwiederholfrequenz gekoppelt sind ##
; ----------------------------------------------------------------------
  CNOP 0,4
no_sync_routines
  rts


; ## Rasterstahl-Routinen ##
; --------------------------
  CNOP 0,4
beam_routines
  bsr     wait_copint
  bsr     swap_second_copperlist
  bsr     spr_swap_structures
  bsr     scs_horiz_scrolltext
  bsr     scs_horiz_scroll
  bsr     hsi_calculate_BPLCON1_values
  bsr     scs_vert_scroll
  bsr     hcs_calculate_planes_x_step
  bsr     hcs_calculate_last_plane_x_speed
  bsr     horiz_characterscrolling
  bsr     scs_set_color_gradients
  bsr     scs_character_vert_scroll
  bsr     radius_fader_in
  bsr     radius_fader_out
  bsr     sb232_get_y_coordinates
  bsr     sb36_get_yz_coordinates
  bsr     sb36_set_background_bars
  bsr     sb36_set_foreground_bars
  bsr     scs_set_center_bar
  bsr     hsi_shrink_logo_x_size
  bsr     move_spaceship_left
  bsr     move_spaceship_right
  bsr     control_counters
  bsr     image_fader_in
  bsr     image_fader_out
  bsr     if_copy_color_table
  bsr     sprite_fader_in
  bsr     sprite_fader_out
  bsr     sprf_copy_color_table
  bsr     bar_fader_in
  bsr     bar_fader_out
  bsr     bf_convert_color_table
  bsr     mouse_handler
  tst.w   fx_state(a3)       ;Effekte beendet ?
  bne     beam_routines      ;Nein -> verzweige
  rts


; ** Copperlisten vertauschen **
; ------------------------------
  SWAP_COPPERLIST cl2,2

; ** Sprites vertauschen **
; -------------------------
  SWAP_SPRITES_STRUCTURES spr,spr_swap_number


; ** Laufschrift **
; -----------------
  CNOP 0,4
scs_horiz_scrolltext
  tst.w   scs_state(a3)      ;Scrolltext an ?
  bne     scs_no_horiz_scrolltext ;Nein -> verzweige
  tst.w   scs_text_move_state(a3) ;Scrolltext-Bewegung an ?
  bne.s   scs_no_horiz_scrolltext ;Nein -> verzweige
  move.w  scs_text_character_x_shift(a3),d2 ;X-Shift-Wert
  addq.w  #scs_horiz_scroll_speed,d2 ;erhöhen
  cmp.w   #scs_text_character_x_shift_max,d2 ;X-Shift-Wert >= Maximum ?
  blt.s   scs_set_character_x_shift ;Nein -> verzweige
scs_new_character_image
  bsr.s   scs_get_new_character_image
  move.l  extra_pf2(a3),a0
  MOVEF.L scs_text_character_x_restart/8,d1
  move.w  scs_text_character_y_offset(a3),d3 ;Y-Offset für Buchstabe
  add.w   d3,d1              ;+ Y-Offset
  add.l   (a0),d1            ;+ Playfieldadresse
  move.w  #DMAF_BLITHOG+DMAF_SETCLR,DMACON-DMACONR(a6) ;BLTPRI an
  WAITBLITTER
  move.l  #(BC0F_SRCA+BC0F_DEST+ANBNC+ANBC+ABNC+ABC)<<16,BLTCON0-DMACONR(a6) ;Minterm D=A
  moveq   #FALSE,d5
  move.l  d5,BLTAFWM-DMACONR(a6) ;Ausmaskierung
  move.l  d0,BLTAPT-DMACONR(a6) ;BOB
  move.l  d1,BLTDPT-DMACONR(a6) ;Playfield
  move.l  #((scs_image_plane_width-scs_text_character_width)<<16)+(extra_pf2_plane_width-scs_text_character_width),BLTAMOD-DMACONR(a6) ;A-Mod + D-Mod
  move.w  #((scs_text_character_y_size/2)*scs_text_character_depth*64)+(scs_text_character_x_size/16),BLTSIZE-DMACONR(a6) ;Blitter starten
  WAITBLITTER
  cmp.w   #(scs_vert_scroll_window_y_size-(scs_text_character_y_size/2))*extra_pf2_plane_width*extra_pf2_depth,d3 ;Befindet sich der Buchstabe außerhalb des Playfieldes ?
  blt.s   scs_normal_blit    ;Nein -> verzweige
  moveq   #scs_text_character_x_restart/8,d1
  add.l   (a0),d1            ;+ Playfieldadresse
  move.l  d1,BLTDPT-DMACONR(a6) ;Playfield
scs_normal_blit
  move.w  #((scs_text_character_y_size/2)*scs_text_character_depth*64)+(scs_text_character_x_size/16),BLTSIZE-DMACONR(a6) ;Blitter starten
  sub.w   #(scs_text_character_y_size/scs_horiz_scroll_speed)*extra_pf2_plane_width*extra_pf2_depth,d3 ;verringern
  bpl.s   scs_set_character_y_offset ;Wenn positiv -> verzweige
  move.w  #(scs_horiz_scroll_window_y_size-(scs_text_character_y_size/2))*extra_pf2_plane_width*extra_pf2_depth,d3 ;Y-Offset zurücksetzen
scs_set_character_y_offset
  move.w  d3,scs_text_character_y_offset(a3) ;Y-Offset retten
  moveq   #TRUE,d2           ;X-Shift-Wert zurücksetzen
scs_set_character_x_shift
  move.w  d2,scs_text_character_x_shift(a3) ;X-Shiftwert
scs_no_horiz_scrolltext
  rts

; ** Neues Image für Character ermitteln **
; -----------------------------------------
  GET_NEW_CHARACTER_IMAGE.W scs,scs_check_control_codes,NORESTART

  CNOP 0,4
scs_check_control_codes
  cmp.b   #"¹",d0
  beq.s   scs_start_sine_bars232
  cmp.b   #"²",d0
  beq.s   scs_start_sine_bars36
  cmp.b   #"",d0
  beq.s   scs_start_radius_fader_out
  cmp.b   #"",d0
  beq.s   scs_start_spaceship_animation
  cmp.b   #"",d0
  beq     scs_start_corkscrew
  cmp.b   #"",d0
  beq     scs_start_normal_scrolltext
  cmp.b   #"",d0
  beq     scs_pause_scrolltext
  cmp.b   #"",d0
  beq     scs_stop_scrolltext
  rts
  CNOP 0,4
scs_start_sine_bars232
  moveq   #FALSE,d0
  move.w  d0,sb36_state(a3)  ;Sine-Bars 3.6 aus
  moveq   #TRUE,d0           ;Rückgabewert TRUE = Steuerungscode gefunden
  move.w  d0,sb232_y_angle(a3) ;Y-Winkel auf 0 Grad zurücksetzen
  move.w  d0,sb232_state(a3) ;Sine-Bars 2.3.2 an
  move.w  d0,rfi_state(a3)   ;Radius-Fader-In an
  moveq   #1,d2
  move.w  d2,rfi_delay_counter(a3) ;Verzögerungszähler aktivieren
  rts
  CNOP 0,4
scs_start_sine_bars36
  moveq   #FALSE,d0
  move.w  d0,sb232_state(a3) ;Sine-Bars 2.3.2 aus
  moveq   #TRUE,d0           ;Rückgabewert TRUE = Steuerungscode gefunden
  move.w  d0,sb36_y_angle(a3) ;Y-Winkel auf 0 Grad zurücksetzen
  move.w  d0,sb36_state(a3)  ;Sine-Bars 3.6 an
  move.w  d0,rfi_state(a3)   ;Radius-Fader-In an
  moveq   #1,d2
  move.w  d2,rfi_delay_counter(a3) ;Verzögerungszähler aktivieren
  rts
  CNOP 0,4
scs_start_radius_fader_out
  moveq   #TRUE,d0           ;Rückgabewert TRUE = Steuerungscode gefunden
  move.w  d0,rfo_state(a3)   ;Radius-Fader-Out an
  moveq   #1,d2
  move.w  d2,rfo_delay_counter(a3) ;Verzögerungszähler aktivieren
  rts
  CNOP 0,4
scs_start_spaceship_animation
  tst.w   msr_state(a3)      ;Fliegt Raumschiff bereits nach rechts ?
  bne.s   scs_no_stop_move_spaceship_right ;Nein -> verzweige
  move.w  #sine_table_length2/2,msr_x_angle(a3) ;180 Grad
scs_no_stop_move_spaceship_right
  bsr     msl_copy_bitmaps
  moveq   #TRUE,d0          ;Rückgabewert TRUE = Steuerungscode gefunden
  move.w  d0,msl_state(a3)  ;Animation nach links starten
  move.w  #sine_table_length2/4,msl_x_angle(a3) ;X-Winkel auf 90 Grad zurücksetzen
  rts
  CNOP 0,4
scs_start_corkscrew
  moveq   #scs_vert_scroll_speed1,d2
  move.w  d2,scs_variable_vert_scroll_speed(a3) ;Vertikale Geschwindigkeit setzen
  moveq   #TRUE,d0          ;Rückgabewert TRUE = Steuerungscode gefunden
  rts
  CNOP 0,4
scs_start_normal_scrolltext
  moveq   #scs_vert_scroll_speed2,d2
  move.w  d2,scs_variable_vert_scroll_speed(a3) ;Vertikale Geschwindigkeit setzen
  moveq   #TRUE,d0          ;Rückgabewert TRUE = Steuerungscode gefunden
  rts
  CNOP 0,4
scs_pause_scrolltext
  moveq   #FALSE,d0
  move.w  d0,scs_text_move_state(a3) ;Text pausieren
  MOVEF.W scs_text_delay,d2
  move.w  d2,scs_text_delay_counter(a3) ;Delay-Counter starten
  moveq   #TRUE,d0           ;Rückgabewert TRUE = Steuerungscode gefunden
  rts
  CNOP 0,4
scs_stop_scrolltext
  moveq   #FALSE,d0
  move.w  d0,scs_state(a3)   ;Text stoppen
  moveq   #TRUE,d0           ;Rückgabewert TRUE = Steuerungscode gefunden
  tst.w   quit_state(a3)     ;Soll Intro beendet werden?
  bne.s   scs_normal_stop_scrolltext ;Nein -> verzweige
scs_quit_and_stop_scrolltext
  move.w  d0,pt_fade_out_music_state(a3) ;Musik ausfaden
  move.w  #if_colors_number*3,if_colors_counter(a3)
  move.w  d0,ifo_state(a3)   ;Image-Fader-Out an
  move.w  d0,if_copy_colors_state(a3) ;Kopieren der Farben an
  move.w  #sprf_colors_number*3,sprf_colors_counter(a3)
  move.w  d0,sprfo_state(a3)   ;Sprite-Fader-Out an
  move.w  d0,sprf_copy_colors_state(a3) ;Kopieren der Farben an
  move.w  #bf_colors_number*3,bf_colors_counter(a3)
  move.w  d0,bf_convert_colors_state(a3) ;Konvertieren der Farben an
  move.w  d0,bfo_state(a3)   ;Bar-Fader-Out an
scs_normal_stop_scrolltext
  rts

; ** Laufschrift horizontal bewegen **
; ------------------------------------
  CNOP 0,4
scs_horiz_scroll
  move.w  #DMAF_BLITHOG,DMACON-DMACONR(a6) ;BLTPRI aus
  tst.w   scs_state(a3)      ;Scrolltext an ?
  bne.s   scs_no_horiz_scroll ;Nein -> verzweige
  tst.w   scs_text_move_state(a3)
  bne.s   scs_no_horiz_scroll
  move.l  extra_pf2(a3),a0
  move.l  (a0),a0
  add.l   #(scs_text_x_position/8)+(scs_text_y_position*extra_pf2_plane_width*extra_pf2_depth),a0 ;Zielbild 48 Pixel später beginnen
  WAITBLITTER
  move.l  #((-scs_horiz_scroll_speed<<12)+BC0F_SRCA+BC0F_DEST+ANBNC+ANBC+ABNC+ABC)<<16,BLTCON0-DMACONR(a6) ;Minterm D=A
  moveq   #FALSE,d0
  move.l  d0,BLTAFWM-DMACONR(a6) ;keine Ausmaskierung
  move.l  a0,BLTDPT-DMACONR(a6) ;Zielbild
  addq.w  #2,a0              ;16 Pixel später beginnen
  move.l  a0,BLTAPT-DMACONR(a6) ;Quellbild
  move.l  #((extra_pf2_plane_width-scs_horiz_scroll_window_width)<<16)+(extra_pf2_plane_width-scs_horiz_scroll_window_width),BLTAMOD-DMACONR(a6) ;A-Mod + D-Mod
  move.w  #(scs_horiz_scroll_window_y_size*scs_horiz_scroll_window_depth*64)+(scs_horiz_scroll_window_x_size/16),BLTSIZE-DMACONR(a6) ;Blitter starten
scs_no_horiz_scroll
  rts

; ** Tabelle für BPLCON1-Register berechnen **
; --------------------------------------------
  CNOP 0,4
hsi_calculate_BPLCON1_values
  move.l  a4,-(a7)
  moveq   #hsi_shift_values_number/2,d3 ;Mittelpunkt
  move.w  hsi_x_radius_angle(a3),d4 ;1. X-Radius-Winkel
  move.w  d4,d0
  addq.b  #hsi_x_radius_angle_speed,d0 ;nächster X-Radius-Winkel
  move.w  d0,hsi_x_radius_angle(a3) 
  move.w  hsi_variable_x_radius_angle_step(a3),d5
  lea     sine_table(pc),a0  
  lea     hsi_radius_table(pc),a1
  lea     hsi_shift_table(pc),a2 ;Zeiger auf Tabelle mit Shiftwerten
  lea     hsi_BPLCON1_table+1(pc),a4 ;Zeiger auf Tabelle mit BPLCON1-Werten
  moveq   #hsi_lines_number-1,d7 ;Anzahl der Zeilen
hsi_calculate_BPLCON1_values_loop1
  move.l  (a0,d4.w*4),d1     ;sin(w)
  MULUF.L hsi_x_radius*2,d1,d0 ;xr'=(xr*sin(w))/2^15
  swap    d1
  add.b   d5,d4              ;nächster X-Radius-Winkel
  addq.w  #hsi_shift_values_number/4,d1 ;xr' + X-Radius-Mittelpunkt
  moveq   #(sine_table_length/4)-(2*hsi_x_angle_step),d2 ;1. X-Winkel
  neg.w   d1                 ;Negation für spätere Berechnung
  moveq   #cl2_display_width-1,d6 ;Anzahl der Einträge in Zieltabelle
hsi_calculate_BPLCON1_values_loop2
  move.w  d1,d0              ;-cos(w)
  muls.w  2(a0,d2.w*4),d0    ;x'=(xr'*(-cos(w)))/2^15
  add.l   d0,d0
  swap    d0
  add.w   d3,d0              ;x' + X-Mittelpunkt
  subq.w  #1,d0              ;Muss sein !
  move.b  (a2,d0.w),(a4)     ;Shiftwert kopieren
  addq.b  #hsi_x_angle_step,d2 ;nächster X-Winkel
  addq.w  #2,a4              ;nächster Eintrag
  dbf     d6,hsi_calculate_BPLCON1_values_loop2
  dbf     d7,hsi_calculate_BPLCON1_values_loop1
  move.l  (a7)+,a4
  rts

; ** Laufschrift vertikal bewegen **
; ----------------------------------
  CNOP 0,4
scs_vert_scroll
  tst.w   scs_state(a3)      ;Scrolltext an ?
  bne.s   scs_no_vert_scroll ;Nein -> verzweige
  move.l  extra_pf2(a3),a0
  move.l  (a0),a0
  add.l   #((scs_text_x_position+16)/8)+(scs_text_y_position*extra_pf2_plane_width*extra_pf2_depth),a0 ;Zielbild 64 Pixel später beginnen
  move.l  extra_pf2(a3),a2
  move.l  (a2),a2
  lea     (vp2_pf_pixel_per_datafetch/8)+(scs_vert_scroll_window_y_size*extra_pf2_plane_width*extra_pf2_depth)(a2),a1 ;Letzte Zeile, 64 Pixel späterbeginnen

; ** vertikaler Umlaufeffekt für die Laufschrift **
  move.w  #DMAF_BLITHOG+DMAF_SETCLR,DMACON-DMACONR(a6) ;BLTPRI an
  WAITBLITTER
  move.w  #BC0F_SRCA+BC0F_DEST+ANBNC+ANBC+ABNC+ABC,BLTCON0-DMACONR(a6) ;Minterm D=A
  move.l  a0,BLTAPT-DMACONR(a6) ;Quelle
  move.l  a1,BLTDPT-DMACONR(a6) ;Ziel
  move.l  #((extra_pf2_plane_width-(scs_vert_scroll_window_width))<<16)+(extra_pf2_plane_width-scs_vert_scroll_window_width),BLTAMOD-DMACONR(a6) ;A-Mod + D-Mod
  move.w  scs_variable_vert_scroll_speed(a3),d0
  MULUF.W scs_vert_scroll_window_depth*64,d0,d1
  or.w    #scs_vert_scroll_window_x_size/16,d0
  move.w  d0,BLTSIZE-DMACONR(a6) ;Blitter starten

; ** Laufschrift vertikal bewegen **
  move.w  scs_variable_vert_scroll_speed(a3),d0
  MULUF.W extra_pf2_plane_width*extra_pf2_depth,d0,d1
  lea     (vp2_pf_pixel_per_datafetch/8)(a2,d0.w),a0 ;Zweite oder dritte Zeile, 64 Pixel späterbeginnen
  lea     (vp2_pf_pixel_per_datafetch/8)(a2),a1 ;Erste Zeile, 64 Pixel späterbeginnen
  WAITBLITTER
  move.w  #DMAF_BLITHOG,DMACON-DMACONR(a6) ;BLTPRI aus
  move.l  a0,BLTAPT-DMACONR(a6) ;Quelle
  move.l  a1,BLTDPT-DMACONR(a6) ;Ziel
  move.w  #(scs_vert_scroll_window_y_size*scs_vert_scroll_window_depth*64)+(scs_vert_scroll_window_x_size/16),BLTSIZE-DMACONR(a6) ;Blitter starten
scs_no_vert_scroll
  rts

; ** Geschwindigkeit der hintersten Ebene berechnen **
; ----------------------------------------------------
  CNOP 0,4
hcs_calculate_last_plane_x_speed
  tst.w   hcs_calculate_last_plane_x_speed_state(a3) ;Berechnung an ?
  bne.s   hcs_no_calculate_last_plane_x_speed ;Nein -> verzweige
  move.w  hcs_last_plane_x_speed_angle(a3),d2  ;X-Speed-Winkel holen
  lea     sine_table(pc),a0
  move.l  (a0,d2.w*4),d0     ;cos(w)
  MULUF.L hcs_last_plane_x_speed_max*2*2,d0,d1 s'=(cos(w)*r)/2^15
  swap    d0
  add.w   #hcs_last_plane_x_speed_max*2,d0 ;+ Mittelpunkt
  move.w  d0,hcs_variable_last_plane_x_speed(a3) ;X-Speed retten
  addq.w  #hcs_last_plane_x_speed_angle_speed,d2 ;nächster Winkel
  cmp.w   #sine_table_length/2,d2 ;180 Grad erreicht ?
  ble.s   hcs_proceed_calculate_last_plane_x_speed ;Ja -> verzweige
  moveq   #FALSE,d0
  move.w  d0,hcs_calculate_last_plane_x_speed_state(a3) ;Berechnung aus
hcs_proceed_calculate_last_plane_x_speed
  move.w  d2,hcs_last_plane_x_speed_angle(a3) ;X-Speed-Winkel retten
hcs_no_calculate_last_plane_x_speed
  rts

; ** Schrittweite zwischen den Ebenen berechnen **
; ------------------------------------------------
  CNOP 0,4
hcs_calculate_planes_x_step
  tst.w   hcs_calculate_planes_x_step_state(a3) ;Berechnung an ?
  bne.s   hcs_no_calculate_planes_x_step ;Nein -> verzweige
  move.w  hcs_planes_x_step_angle(a3),d2 ;X-Step-Winkel holen
  lea     sine_table(pc),a0
  move.l  (a0,d2.w*4),d0     ;cos(w)
  MULUF.L hcs_planes_x_step_max*2*2,d0,d1 ;s'=(cos(w)*r)/2^15
  swap    d0
  add.w   #(hcs_planes_x_step_max*2)+1,d0 ;+ Mittelpunkt
  move.w  d0,hcs_variable_planes_x_step(a3) ;X-Step retten
  addq.w  #hcs_planes_x_step_angle_speed,d2 ;nächster Winkel
  cmp.w   #sine_table_length/2,d2 ;180 Grad erreicht ?
  ble.s   hcs_proceed_calculate_planes_x_step ;Ja -> verzweige
  moveq   #FALSE,d0
  move.w  d0,hcs_calculate_planes_x_step_state(a3) ;Berechnung aus
hcs_proceed_calculate_planes_x_step
  move.w  d2,hcs_planes_x_step_angle(a3) ;X-Step-Winkel retten
hcs_no_calculate_planes_x_step
  rts

; ** RSE-Buchstaben horizontal bewegen **
; ---------------------------------------
  CNOP 0,4
horiz_characterscrolling
  movem.l a4-a6,-(a7)
  MOVEF.W FALSEB-SPRCTLF_SH2-SPRCTLF_SH0-SPRCTLF_SH1,d2 ;Maske für SH0,SH1,SH2-Bits
  move.w  hcs_variable_last_plane_x_speed(a3),d3
  moveq   #TRUE,d4           ;Für Übertrag X-Bit
  IFNE hcs_quick_x_max_restart
    move.w  #hcs_x_max,d5
  ENDC
  lea     spr_pointers_construction+(hcs_planes_number*8)(pc),a2 ;Zeiger auf letztes Sprite
  IFNE hcs_quick_x_max_restart
    move.w  #hcs_sprite_x_restart,a4
  ENDC
  lea     hcs_objects_x_coordinates(pc),a5 ;Zeiger auf X-Koords.
  move.w  #spr2_extension1_SIZE,a6
  moveq   #hcs_planes_number-1,d7 ;Anzahl der Ebenen
hcs_horiz_ballscrolling_loop1
  move.l  -(a2),a1           ;Zeiger auf 2. Sprite-Struktur
  addq.w  #1,a1              ;SPRxPOS Lowbyte
  move.l  -(a2),a0           ;Zeiger auf 1. Sprite-Struktur
  addq.w  #1,a0              ;SPRxPOS Lowbyte
  moveq   #hcs_objects_per_sprite_number-1,d6 ;Anzahl der Bälle pro Sprite
hcs_horiz_ballscrolling_loop2
  move.b  spr_pixel_per_datafetch/8(a0),d1 ;SPRxCTL Lowbyte lesen
  and.b   d2,d1              ;SH0,SH1,SH2-Bits löschen
  move.w  (a5),d0            ;X-Koord. holen
  add.w   d3,d0              ;X erhöhen
  IFEQ hcs_quick_x_max_restart
    and.w  d5,d0             ;Überlauf entfernen
  ELSE
    cmp.w   d5,d0            ;X > X-Max ?
    ble.s   hcs_x_ok         ;Nein -> verzweige
    sub.w   a4,d0            ;X zurücksetzen
hcs_x_ok
  ENDC
  move.w  d0,(a5)+           ;X retten
  lsl.w   #5,d0              ;%SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3 SH2 SH1 SH0 --- --- --- --- ---
  add.b   d0,d0              ;% SH1 SH0 --- --- --- --- --- ---
  addx.b  d4,d1              ;% --- --- --- --- --- SV8 EV8 SH2
  lsr.b   #3,d0              ;% --- --- --- SH1 SH0 --- --- ---
  or.b    d0,d1              ;% --- --- --- SH1 SH0 SV8 EV8 SH2
  move.b  d1,spr_pixel_per_datafetch/8(a0) ;SPRxCTL Lowbyte setzen
  lsr.w   #8,d0              ;% --- --- --- --- --- --- --- --- SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3: SH10-SH3 = SPRxPOS Lowbyte
  move.b  d0,(a0)            ;SPRxPOS Lowbyte setzen
  tas     d1                 ;% ATT --- --- SH1 SH0 SV8 EV8 SH2: ATT-Bit setzen
  move.b  d0,(a1)            ;SPRxPOS Lowbyte setzen
  add.l   a6,a0              ;nächstes Sprite
  move.b  d1,spr_pixel_per_datafetch/8(a1) ;SPRxCTL Lowbyte setzen
  add.l   a6,a1              ;nächstes Sprite
  dbf     d6,hcs_horiz_ballscrolling_loop2
  add.w   hcs_variable_planes_x_step(a3),d3 ;Geschwindigkeit der nächsten Ebene
  dbf     d7,hcs_horiz_ballscrolling_loop1
  movem.l (a7)+,a4-a6
  rts

; ** Buchstaben vertikal bewegen **
; ---------------------------------
  CNOP 0,4
scs_character_vert_scroll
  tst.w   scs_state(a3)      ;Scrolltext an ?
  bne.s   scs_no_character_vert_scroll ;Nein -> verzweige
  move.l  extra_pf2(a3),a2
  move.l  (a2),a2
  lea     (extra_pf2_x_size-vp2_pf_pixel_per_datafetch)/8(a2),a0 ;Erste Zeile, rechter Rand abzüglich 64 Pixel
  lea     ((extra_pf2_x_size-vp2_pf_pixel_per_datafetch)/8)+(scs_vert_scroll_window_y_size*extra_pf2_plane_width*extra_pf2_depth)(a2),a1 ;Letzte Zeile rechter Rand abzüglich 64 Pixel
; ** vertikaler Umlaufeffekt für Zeichen **
  move.w  #DMAF_BLITHOG+DMAF_SETCLR,DMACON-DMACONR(a6) ;BLTPRI an
  WAITBLITTER
  move.w  #BC0F_SRCA+BC0F_DEST+ANBNC+ANBC+ABNC+ABC,BLTCON0-DMACONR(a6) ;Minterm D=A
  move.l  a0,BLTAPT-DMACONR(a6) ;Quelle
  move.l  a1,BLTDPT-DMACONR(a6) ;Ziel
  move.l  #((extra_pf2_plane_width-scs_text_character_width)<<16)+(extra_pf2_plane_width-scs_text_character_width),BLTAMOD-DMACONR(a6) ;A-Mod + D-Mod
  MOVEF.W (scs_text_character_vert_scroll_speed*scs_vert_scroll_window_depth*64)+(scs_text_character_x_size/16),d1
  move.w  d1,BLTSIZE-DMACONR(a6) ;Blitter starten

; ** Buchstaben vertikal bewegen **
  lea     ((extra_pf2_x_size-vp2_pf_pixel_per_datafetch)/8)+(scs_text_character_vert_scroll_speed*extra_pf2_plane_width*extra_pf2_depth)(a2),a0 ;Zweite Zeile, rechter Rand abzüglich 64 Pixel
  lea     (extra_pf2_x_size-vp2_pf_pixel_per_datafetch)/8(a2),a1 ;Erste, Zeile rechter Rand abzüglich 64 Pixel
  WAITBLITTER
  move.w  #DMAF_BLITHOG,DMACON-DMACONR(a6) ;BLTPRI aus
  move.l  a0,BLTAPT-DMACONR(a6) ;Quelle
  move.l  a1,BLTDPT-DMACONR(a6) ;Ziel
  move.w  #(scs_vert_scroll_window_y_size*scs_vert_scroll_window_depth*64)+(scs_text_character_x_size/16),BLTSIZE-DMACONR(a6) ;Blitter starten
scs_no_character_vert_scroll
  rts

; ** Y-Koordinaten berechnen **
; -----------------------------
  CNOP 0,4
sb232_get_y_coordinates
  tst.w   sb232_state(a3)    ;Sine-Bars 2.3.2 an ?
  bne     no_sine_bars232    ;Nein -> verzweige
  tst.w   sb_variable_y_radius(a3) ;Y-Radius Null ?
  beq     no_sine_bars232    ;Ja -> verzweige
  movem.l a4-a6,-(a7)
  move.w  sb232_y_radius_angle(a3),d3 ;1. Y-Radius-Winkel
  move.w  d3,d0
  move.w  sb232_y_angle(a3),d4 ;1. Y-Winkel
  addq.b  #sb232_y_radius_angle_speed,d0 ;nächster Y-Radius-Winkel
  move.w  d0,sb232_y_radius_angle(a3) ;Y-Radius-Winkel retten
  move.w  d4,d0
  addq.b  #sb232_y_angle_speed,d0 ;nächster Y-Winkel
  move.w  d0,sb232_y_angle(a3) ;Y-Winkel retten
  lea     sine_table(pc),a0  
  move.w  #sb232_y_center,a1
  move.l  cl2_construction2(a3),a5 
  ADDF.W  cl2_extension6_entry+cl2_ext6_COLOR00_high+2,a5
  move.w  #cl2_extension6_SIZE,a6
  moveq   #sb232_bars_number-1,d7 ;Anzahl der Stangen
sb232_get_y_coordinates_loop1
  move.w  2(a0,d3.w*4),d0    ;sin(w)
  muls.w  sb_variable_y_radius(a3),d0 ;yr'=(yr*sin(w))/2^15
  swap    d0
  addq.b  #sb232_y_radius_angle_step,d3 ;nächster Y-Radius-Winkel
  muls.w  2(a0,d4.w*4),d0    ;y'=(yr'*sin(w))/2^15
  add.l   d0,d0
  swap    d0
  ADDF.B  sb232_y_distance,d4 ;Y-Abstand zu nächster Bar
  add.w   a1,d0              ;y' + Y-Mittelpunkt
  MULUF.W cl2_extension6_SIZE/4,d0,d1 ;Y-Offset in CL
  lea     (a5,d0.w*4),a2     ;Y-Offset
  lea     scs_bar_color_table(pc),a4
  moveq   #sb_bar_height-1,d6 ;Höhe der Bar
sb232_get_y_coordinates_loop2
  move.l  (a4)+,d0
  move.w  d0,cl2_ext6_COLOR00_low-cl2_ext6_COLOR00_high(a2) ;COLOR00 Low-Bits
  move.w  d0,cl2_ext6_COLOR05_low-cl2_ext6_COLOR00_high(a2) ;COLOR05 Low-Bits
  move.w  d0,cl2_ext6_COLOR06_low-cl2_ext6_COLOR00_high(a2) ;COLOR06 Low-Bits
  swap    d0                 ;High-Bits
  move.w  d0,(a2)            ;COLOR00 High-Bits
  move.w  d0,cl2_ext6_COLOR05_high-cl2_ext6_COLOR00_high(a2) ;COLOR05 High-Bits
  add.l   a6,a2              ;nächste Zeile
  move.w  d0,(cl2_ext6_COLOR06_high-cl2_ext6_COLOR00_high)-cl2_extension6_SIZE(a2) ;COLOR06 High-Bits
  dbf     d6,sb232_get_y_coordinates_loop2
  dbf     d7,sb232_get_y_coordinates_loop1
  movem.l (a7)+,a4-a6
no_sine_bars232
  rts

; ** Y+Z-Koordinaten berechnen **
; -------------------------------
  CNOP 0,4
sb36_get_yz_coordinates
  tst.w   sb36_state(a3)
  bne.s   sb36_no_get_yz_coordinates
  tst.w   sb_variable_y_radius(a3)
  beq.s   sb36_no_get_yz_coordinates
  move.l  a4,-(a7)
  move.w  sb36_y_angle(a3),d2 ;1. Y-Winkel
  move.w  d2,d0              
  move.w  sb36_y_distance_angle(a3),d4 ;1. Y-Distance-Winkel
  addq.b  #sb36_y_angle_speed,d0
  move.w  d0,sb36_y_angle(a3) 
  move.w  d4,d0
  addq.b  #sb36_y_distance_speed,d0
  move.w  d0,sb36_y_distance_angle(a3) 
  lea     sine_table(pc),a0  
  lea     sb36_yz_coordinates(pc),a1 ;Zeiger auf Y+Z-Koords-Tabelle
  move.w  #sb36_y_center,a2
  move.w  #sb36_y_distance_center,a4
  moveq   #sb36_bars_number-1,d7 ;Anzahl der Stangen
sb36_get_yz_coordinates_loop
  moveq   #-(sine_table_length/4),d1 ;- 90 Grad
  move.w  2(a0,d2.w*4),d0    ;sin(w)
  add.w   d2,d1              ;Y-Winkel - 90 Grad
  ext.w   d1                 ;Vorzeichenrichtig auf ein Wort erweitern
  move.w  d1,(a1)+           ;Z-Vektor retten
  muls.w  sb_variable_y_radius(a3),d0 ;y'=(yr*sin(w))/2^15
  swap    d0
  add.w   a2,d0              ;y' + Y-Mittelpunkt
  MULUF.W cl2_extension6_SIZE/4,d0,d1 ;Y-Offset in CL
  move.l  (a0,d4.w*4),d3     ;sin(w)
  MULUF.L sb36_y_distance_radius*2,d3,d1 ;y'=(yr*sin(w))/2^15
  swap    d3
  move.w  d0,(a1)+           ;Y retten
  add.w   a4,d3              ;y' + Y-Distance-Mittelpunkt
  addq.b  #sb36_y_distance_step1,d4 ;nächster Y-Distance-Winkel
  add.b   d3,d2              ;Y-Abstand zur nächsten Bar
  dbf     d7,sb36_get_yz_coordinates_loop
  move.l  (a7)+,a4
sb36_no_get_yz_coordinates
  rts

; ** Hintere Stangen in Copperliste kopieren **
; ---------------------------------------------
  CNOP 0,4
sb36_set_background_bars
  tst.w   sb36_state(a3)     ;Sine-Bars 3.6 an ?
  bne.s   sb36_no_set_background_bars ;Nein -> verzweige
  tst.w   sb_variable_y_radius(a3) ;Y-Radius Null ?
  beq.s   sb36_no_set_background_bars ;Ja -> verzweige
  move.l  a4,-(a7)
  MOVEF.L cl2_extension6_SIZE,d5
  lea     sb36_yz_coordinates(pc),a0 ;Zeiger auf YZ-Koords
  move.l  cl2_construction2(a3),a2 
  ADDF.W  cl2_extension6_entry+cl2_ext6_COLOR00_high+2,a2
  moveq   #sb36_bars_number-1,d7 ;Anzahl der Stangen
sb36_set_background_bars_loop1
  move.l  (a0)+,d0           ;Z + Y lesen
  bmi.s   sb36_no_background_bar ;Wenn Z negativ -> verzweige
sb36_set_background_bar
  lea     scs_bar_color_table(pc),a1
  lea     (a2,d0.w*4),a4     ;Y-Offset
  moveq   #sb_bar_height-1,d6 ;Höhe der Bar
sb36_set_background_bars_loop2
  move.l  (a1)+,d0
  move.w  d0,cl2_ext6_COLOR00_low-cl2_ext6_COLOR00_high(a4) ;COLOR00 Low-Bits
  move.w  d0,cl2_ext6_COLOR05_low-cl2_ext6_COLOR00_high(a4) ;COLOR05 Low-Bits
  move.w  d0,cl2_ext6_COLOR06_low-cl2_ext6_COLOR00_high(a4) ;COLOR06 Low-Bits
  swap    d0                 ;High-Bits
  move.w  d0,(a4)            ;COLOR00 High-Bits
  move.w  d0,cl2_ext6_COLOR05_high-cl2_ext6_COLOR00_high(a4) ;COLOR05 High-Bits
  add.l   d5,a4              ;nächste Zeile in CL
  move.w  d0,(cl2_ext6_COLOR06_high-cl2_ext6_COLOR00_high)-cl2_extension6_SIZE(a4) ;COLOR06 High-Bits
  dbf     d6,sb36_set_background_bars_loop2
sb36_no_background_bar
  dbf     d7,sb36_set_background_bars_loop1
  move.l  (a7)+,a4
sb36_no_set_background_bars
  rts

; ** Vordere Stangen in Copperliste kopieren **
; ---------------------------------------------
  CNOP 0,4
sb36_set_foreground_bars
  tst.w   sb36_state(a3)     ;Sine-Bars 3.6 an ?
  bne.s   sb36_no_set_foreground_bars ;Nein -> verzweige
  tst.w   sb_variable_y_radius(a3) ;Y-Radius Null ?
  beq.s   sb36_no_set_foreground_bars ;Ja -> verzweige
  move.l  a4,-(a7)
  MOVEF.L cl2_extension6_SIZE,d5
  lea     sb36_yz_coordinates(pc),a0 ;Zeiger auf YZ-Koords
  move.l  cl2_construction2(a3),a2 
  ADDF.W  cl2_extension6_entry+cl2_ext6_COLOR00_high+2,a2
  moveq   #sb36_bars_number-1,d7 ;Anzahl der Stangen
sb36_set_foreround_bars_loop1
  move.l  (a0)+,d0           ;Z + Y lesen
  bpl.s   sb36_no_foreground_bar ;Wenn Z positiv -> verzweige
sb36_set_foreground_bar
  lea     scs_bar_color_table(pc),a1
  lea     (a2,d0.w*4),a4     ;Y-Offset
  moveq   #sb_bar_height-1,d6 ;Höhe der Bar
sb36_set_foreround_bars_loop2
  move.l  (a1)+,d0
  move.w  d0,cl2_ext6_COLOR00_low-cl2_ext6_COLOR00_high(a4) ;COLOR00 Low-Bits
  move.w  d0,cl2_ext6_COLOR05_low-cl2_ext6_COLOR00_high(a4) ;COLOR05 Low-Bits
  move.w  d0,cl2_ext6_COLOR06_low-cl2_ext6_COLOR00_high(a4) ;COLOR06 Low-Bits
  swap    d0                 ;High-Bits
  move.w  d0,(a4)            ;COLOR00 High-Bits
  move.w  d0,cl2_ext6_COLOR05_high-cl2_ext6_COLOR00_high(a4) ;COLOR05 High-Bits
  add.l   d5,a4              ;nächste Zeile in CL
  move.w  d0,(cl2_ext6_COLOR06_high-cl2_ext6_COLOR00_high)-cl2_extension6_SIZE(a4) ;COLOR06 High-Bits
  dbf     d6,sb36_set_foreround_bars_loop2
sb36_no_foreground_bar
  dbf     d7,sb36_set_foreround_bars_loop1
  move.l  (a7)+,a4
sb36_no_set_foreground_bars
  rts

; ** Center-Bar setzen **
; -----------------------
  CNOP 0,4
scs_set_center_bar
  tst.w   sb_variable_y_radius(a3) ;Y-Radius Null ?
  bne.s   scs_no_set_center_bar ;Nein -> verzweige
  lea     scs_bar_color_table(pc),a0 ;Zeiger auf Farbtabelle
  move.l  cl2_construction2(a3),a1 
  ADDF.W  (cl2_extension6_entry+cl2_ext6_COLOR00_high+2)+(((vp2_visible_lines_number-scs_center_bar_height)/2)*cl2_extension6_SIZE),a1 ;Zentrierung
  move.w  #cl2_extension6_SIZE,a2
  moveq   #scs_center_bar_height-1,d7 ;Anzahl der Farbwerte
scs_set_center_bar_loop
  move.l  (a0)+,d0
  move.w  d0,cl2_ext6_COLOR00_low-cl2_ext6_COLOR00_high(a1) ;COLOR00 Low-Bits
  move.w  d0,cl2_ext6_COLOR05_low-cl2_ext6_COLOR00_high(a1) ;COLOR05 Low-Bits
  move.w  d0,cl2_ext6_COLOR06_low-cl2_ext6_COLOR00_high(a1) ;COLOR06 Low-Bits
  swap    d0                 ;High-Bits
  move.w  d0,(a1)            ;COLOR00 High-Bits
  move.w  d0,cl2_ext6_COLOR05_high-cl2_ext6_COLOR00_high(a1) ;COLOR05 High-Bits
  add.l   a2,a1              ;nächste Zeile in CL
  move.w  d0,(cl2_ext6_COLOR06_high-cl2_ext6_COLOR00_high)-cl2_extension6_SIZE(a1) ;COLOR06 High-Bits
  dbf     d7,scs_set_center_bar_loop
scs_no_set_center_bar
  rts

; ** BPLCON1-Werte in Copperliste kopieren und Logo horizontal stauchen **
; ------------------------------------------------------------------------
  CNOP 0,4
hsi_shrink_logo_x_size
  MOVEF.W $ff,d2             ;Scroll-Maske H0-H7
  lea     hsi_BPLCON1_table(pc),a0 ;Tabelle mit Shiftwerten
  move.l  cl2_construction2(a3),a1
  move.w  (a0)+,d0
  BITPLANE_SOFTSCROLL_64PIXEL_LORES d0,d1,d2
  move.w  d0,cl2_extension2_entry+cl2_ext2_BPLCON1+2(a1) ;BPLCON1
  ADDF.W  cl2_extension3_entry+cl2_ext3_BPLCON1_1+2,a1 
  moveq   #hsi_lines_number-1,d7 ;Anzahl der Zeilen
hsi_shrink_logo_x_size_loop1
  moveq   #cl2_display_width-1,d6 ;Anzahl der Spalten
hsi_shrink_logo_x_size_loop2
  move.w  (a0)+,d0           ;Shiftwert lesen
  BITPLANE_SOFTSCROLL_64PIXEL_LORES d0,d1,d2
  move.w  d0,(a1)            ;BPLCON1
  addq.w  #4,a1
  dbf     d6,hsi_shrink_logo_x_size_loop2
  addq.w  #4,a1              ;CWAIT überspringen
  dbf     d7,hsi_shrink_logo_x_size_loop1
  rts

; ** Raumschiff horizontal nach links bewegen **
; ----------------------------------------------
  CNOP 0,4
move_spaceship_left
  tst.w   msl_state(a3)      ;Bewegung nach links an ?
  bne.s   no_move_spaceship_left ;Nein -> verzweige
  move.w  msl_x_angle(a3),d2 ;X-Winkel holen
  lea     sine_table_512(pc),a0
  move.w  (a0,d2.w*2),d1     ;cos(w)
  muls.w  #ms_x_radius*4*2,d1 x'=(cos(w)*rx)/2^15
  swap    d1
  add.w   #ms_x_center*4,d1  ;X ;+ X-Mittelpunkt
  addq.w  #msl_x_angle_speed,d2 ;nächster X-Winkel
  cmp.w   #sine_table_length2/2,d2 ;180 Grad erreicht ?
  bgt.s   msl_finished      ;Ja -> verzweige
msl_save_x_angle
  move.w  d2,msl_x_angle(a3) ;X-Winkel retten
  move.w  #display_window_HSTOP*4,d0
  sub.w   d1,d0              ;HSTART: X-Zentrierung
  MOVEF.W msl_spaceship_y_position,d1 ;VSTART
  moveq   #ms_image_y_size,d2 ;Höhe
  add.w   d1,d2              ;VSTOP
  lea     spr_pointers_construction(pc),a2 ;Zeiger auf Sprites
  move.l  (a2)+,a0           ;Zeiger auf 1. Sprite-Struktur
  ADDF.W  spr0_extension2_entry,a0
  move.l  (a2),a1            ;Zeiger auf 2. Sprite-Struktur
  ADDF.W  spr1_extension2_entry,a1
  SET_SPRITE_POSITION d0,d1,d2
  move.w  d1,(a0)            ;SPRxPOS
  move.w  d2,spr_pixel_per_datafetch/8(a0) ;SPRxCTL
  tas     d2                 ;Attached-Bit setzen
  move.w  d1,(a1)            ;SPRxPOS
  move.w  d2,spr_pixel_per_datafetch/8(a1) ;SPRxCTL
no_move_spaceship_left
  rts
  CNOP 0,4
msl_finished
  moveq   #FALSE,d0
  move.w  d0,msl_state(a3)   ;Bewegung nach links aus
  bsr     msr_copy_bitmaps
  clr.w   msr_state(a3)      ;Bewegung nach rechts an
  move.w  #sine_table_length2/4,msr_x_angle(a3) ;X-Winkel auf 180 Grad zurücksetzen
  rts

; ** Spaceship-Grafik kopieren **
; -------------------------------
  CNOP 0,4
msl_copy_bitmaps
  lea     msl_image_data,a2
  bra     ms_copy_image_data

; ** Raumschiff horizontal nach rechts bewegen **
; -----------------------------------------------
  CNOP 0,4
move_spaceship_right
  tst.w   msr_state(a3)      ;Bewegung nach rechts an ?
  bne.s   no_move_spaceship_right ;Nein -> verzweige
  move.w  msr_x_angle(a3),d2 ;X-Winkel holen
  lea     sine_table_512(pc),a0
  move.w  (a0,d2.w*2),d1     ;cos(w)
  muls.w  #ms_x_radius*4*2,d1 x'=(cos(w)*rx)/2^15
  swap    d1
  add.w   #ms_x_center*4,d1  ;X ;+ X-Mittelpunkt
  addq.w  #msr_x_angle_speed,d2 ;nächster X-Winkel
  cmp.w   #sine_table_length2/2,d2 ;180 Grad erreicht ?
  bgt.s   msr_finished       ;Ja -> verzweige
msr_save_x_angle
  move.w  d2,msr_x_angle(a3) ;X-Winkel retten
  move.w  #(display_window_HSTART-ms_image_x_size)*4,d0
  add.w   d1,d0              ;HSTOP: X-Zentrierung
  MOVEF.W msl_spaceship_y_position,d1 ;VSTART
  moveq   #ms_image_y_size,d2 ;Höhe
  add.w   d1,d2              ;VSTOP
  lea     spr_pointers_construction(pc),a2 ;Zeiger auf Sprites
  move.l  (a2)+,a0           ;Zeiger auf 1. Sprite-Struktur
  ADDF.W  spr0_extension2_entry,a0
  move.l  (a2),a1            ;Zeiger auf 2. Sprite-Struktur
  ADDF.W  spr1_extension2_entry,a1
  SET_SPRITE_POSITION d0,d1,d2
  move.w  d1,(a0)            ;SPRxPOS
  move.w  d2,spr_pixel_per_datafetch/8(a0) ;SPRxCTL
  tas     d2                 ;Attached-Bit setzen
  move.w  d1,(a1)            ;SPRxPOS
  move.w  d2,spr_pixel_per_datafetch/8(a1) ;SPRxCTL
no_move_spaceship_right
  rts
  CNOP 0,4
msr_finished
  moveq   #FALSE,d0
  move.w  d0,msr_state(a3)   ;Bewegung nach rechts aus
  rts

; ** Spaceship-Grafik kopieren **
; -------------------------------
  CNOP 0,4
msr_copy_bitmaps
  lea     msr_image_data,a2

; ** Routine copy_image_data **
; a2 ... Grafikdaten
ms_copy_image_data
  movem.l d1/a0/a4-a6,-(a7)
  lea     spr_pointers_construction(pc),a5 ;Zeiger auf Sprites
  move.l  (a5)+,a0           ;Zeiger auf 1. Sprite-Struktur
  ADDF.W  spr0_extension2_entry+((spr_pixel_per_datafetch/8)*2),a0 ;Header überspringen
  move.l  (a5),a1            ;Zeiger auf 2. Sprite-Struktur
  ADDF.W  spr1_extension2_entry+((spr_pixel_per_datafetch/8)*2),a1 ;Header überspringen
  lea     spr_pointers_display(pc),a5 ;Zeiger auf Sprites
  move.l  (a5)+,a4           ;Zeiger auf 1. Sprite-Struktur
  ADDF.W  spr0_extension2_entry+((spr_pixel_per_datafetch/8)*2),a4 ;Header überspringen
  move.l  (a5),a5            ;Zeiger auf 2. Sprite-Struktur
  ADDF.W  spr1_extension2_entry+((spr_pixel_per_datafetch/8)*2),a5 ;Header überspringen
  moveq   #ms_image_y_size-1,d7 ;Anzahl der Zeilen
ms_copy_image_data_loop
  movem.l (a2)+,d0-d6/a6     ;64 Pixel für 4 Bitplanes lesen
  move.l  d0,(a0)+           ;Plane0 gerades Sprite
  move.l  d1,(a0)+
  move.l  d2,(a0)+           ;Plane1 gerades Sprite
  move.l  d3,(a0)+
  move.l  d4,(a1)+           ;Plane0 ungerades Sprite
  move.l  d5,(a1)+
  move.l  d6,(a1)+           ;Plane1 ungerades Sprite
  move.l  a6,(a1)+

  move.l  d0,(a4)+           ;Plane0 gerades Sprite
  move.l  d1,(a4)+
  move.l  d2,(a4)+           ;Plane1 gerades Sprite
  move.l  d3,(a4)+
  move.l  d4,(a5)+           ;Plane0 ungerades Sprite
  move.l  d5,(a5)+
  move.l  d6,(a5)+           ;Plane1 ungerades Sprite
  move.l  a6,(a5)+
  dbf     d7,ms_copy_image_data_loop
  movem.l (a7)+,d1/a0/a4-a6
  rts


; ** Verzögerungszähler **
; ------------------------
  CNOP 0,4
control_counters
  move.w  scs_text_delay_counter(a3),d0 ;Zählerwert holen
  bmi.s   scs_no_text_delay_counter ;Wenn negativ -> verzweige
  subq.w  #1,d0              ;Wert verringern
  bpl.s   scs_save_text_delay_counter ;Wenn positiv -> verzweige
scs_disable_text_delay_counter
  clr.w   scs_text_move_state(a3) ;Laufschrift-Bewegung an
  moveq   #FALSE,d0          ;Zähler stoppen
scs_save_text_delay_counter
  move.w  d0,scs_text_delay_counter(a3) 
scs_no_text_delay_counter
  rts


; ** Radius-Fader-In **
; ---------------------
  CNOP 0,4
radius_fader_in
  tst.w   rfi_state(a3)      ;Radius-Fader-In an ?
  bne.s   no_radius_fader_in ;Nein -> verzweige
  subq.w  #rfi_delay_speed,rfi_delay_counter(a3) ;Verzögerungszähler herunterzählen
  bgt.s   no_radius_fader_in ;Wenn > 0 -> verzweige
  moveq   #rfi_delay,d2
  move.w  d2,rfi_delay_counter(a3) ;Verzögerungszähler zurücksetzen
  move.w  sb_variable_y_radius(a3),d0 ;Y-Radius holen
  cmp.w   #rf_max_y_radius,d0 ;Maximalwert erreicht ?
  bge.s   rfi_finished       ;Ja -> verzweige
  addq.w  #rfi_speed,d0      ;Y-Radius erhöhen
  move.w  d0,sb_variable_y_radius(a3) 
no_radius_fader_in
  rts
  CNOP 0,4
rfi_finished
  moveq   #FALSE,d0
  move.w  d0,rfi_state(a3)   ;Radius-Fader-In aus
  rts

; ** Radius-Fader-Out **
; ----------------------
  CNOP 0,4
radius_fader_out
  tst.w   rfo_state(a3)      ;Radius-Fader-Out an ?
  bne.s   no_radius_fader_out ;Nein -> verzweige
  subq.w  #rfo_delay_speed,rfo_delay_counter(a3) ;Verzögerungszähler herunterzählen
  bgt.s   no_radius_fader_out ;Wenn > 0 -> verzweige
  moveq   #rfo_delay,d2
  move.w  d2,rfo_delay_counter(a3) ;Verzögerungszähler zurücksetzen
  move.w  sb_variable_y_radius(a3),d0 ;Y-Radius holen
  ble.s   rfo_finished       ;Wenn Minimalwert erreicht -> verzweige
  subq.w  #rfo_speed,d0      ;Y-Radius verringern
  move.w  d0,sb_variable_y_radius(a3) 
no_radius_fader_out
  rts
  CNOP 0,4
rfo_finished
  moveq   #FALSE,d0
  move.w  d0,rfo_state(a3)   ;Berechnung aus
  rts

; ** Logo einblenden **
; ---------------------
  CNOP 0,4
image_fader_in
  tst.w   ifi_state(a3)      ;Image-Fader-In an ?
  bne.s   no_image_fader_in  ;Nein -> verzweige
  movem.l a4-a6,-(a7)
  move.w  ifi_fader_angle(a3),d2 ;Fader-Winkel holen
  move.w  d2,d0
  ADDF.W  ifi_fader_angle_speed,d0 ;nächster Fader-Winkel
  cmp.w   #sine_table_length/2,d0 ;Y-Winkel <= 180 Grad ?
  ble.s   ifi_no_restart_fader_angle ;Ja -> verzweige
  MOVEF.W sine_table_length/2,d0 ;180 Grad
ifi_no_restart_fader_angle
  move.w  d0,ifi_fader_angle(a3) ;Fader-Winkel retten
  MOVEF.W if_colors_number*3,d6 ;Zähler
  lea     sine_table(pc),a0  ;Sinus-Tabelle
  move.l  (a0,d2.w*4),d0     ;sin(w)
  MULUF.L ifi_fader_radius*2,d0,d1 ;y'=(yr*sin(w))/2^15
  swap    d0
  ADDF.W  ifi_fader_center,d0 ;+ Fader-Mittelpunkt
  lea     pf1_color_table+(if_color_table_offset*LONGWORDSIZE)(pc),a0 ;Puffer für Farbwerte
  lea     ifi_color_table+(if_color_table_offset*LONGWORDSIZE)(pc),a1 ;Sollwerte
  move.w  d0,a5              ;Additions-/Subtraktionswert für Blau
  swap    d0                 ;WORDSHIFT
  clr.w   d0                 ;Bits 0-15 löschen
  move.l  d0,a2              ;Additions-/Subtraktionswert für Rot
  lsr.l   #8,d0              ;BYTESHIFT
  move.l  d0,a4              ;Additions-/Subtraktionswert für Grün
  MOVEF.W if_colors_number-1,d7 ;Anzahl der Farben
  bsr     if_fader_loop
  movem.l (a7)+,a4-a6
  move.w  d6,if_colors_counter(a3) ;Image-Fader-In fertig ?
  bne.s   no_image_fader_in  ;Nein -> verzweige
  moveq   #FALSE,d0
  move.w  d0,ifi_state(a3)   ;Image-Fader-In aus
no_image_fader_in
  rts

; ** Logo ausblenden **
; ---------------------
  CNOP 0,4
image_fader_out
  tst.w   ifo_state(a3)      ;Image-Fader-Out an ?
  bne.s   no_image_fader_out ;Nein -> verzweige
  movem.l a4-a6,-(a7)
  move.w  ifo_fader_angle(a3),d2 ;Fader-Winkel holen
  move.w  d2,d0
  ADDF.W  ifo_fader_angle_speed,d0 ;nächster Fader-Winkel
  cmp.w   #sine_table_length/2,d0 ;Y-Winkel <= 180 Grad ?
  ble.s   ifo_no_restart_fader_angle ;Ja -> verzweige
  MOVEF.W sine_table_length/2,d0 ;180 Grad
ifo_no_restart_fader_angle
  move.w  d0,ifo_fader_angle(a3) ;Fader-Winkel retten
  MOVEF.W if_colors_number*3,d6 ;Zähler
  lea     sine_table(pc),a0  ;Sinus-Tabelle
  move.l  (a0,d2.w*4),d0     ;sin(w)
  MULUF.L ifo_fader_radius*2,d0,d1 ;y'=(yr*sin(w))/2^15
  swap    d0
  ADDF.W  ifo_fader_center,d0 ;+ Fader-Mittelpunkt
  lea     pf1_color_table+(if_color_table_offset*LONGWORDSIZE)(pc),a0 ;Puffer für Farbwerte
  lea     ifo_color_table+(if_color_table_offset*LONGWORDSIZE)(pc),a1 ;Sollwerte
  move.w  d0,a5              ;Additions-/Subtraktionswert für Blau
  swap    d0                 ;WORDSHIFT
  clr.w   d0                 ;Bits 0-15 löschen
  move.l  d0,a2              ;Additions-/Subtraktionswert für Rot
  lsr.l   #8,d0              ;BYTESHIFT
  move.l  d0,a4              ;Additions-/Subtraktionswert für Grün
  MOVEF.W if_colors_number-1,d7 ;Anzahl der Farben
  bsr.s   if_fader_loop
  movem.l (a7)+,a4-a6
  move.w  d6,if_colors_counter(a3) ;Image-Fader-Out fertig ?
  bne.s   no_image_fader_out ;Nein -> verzweige
  moveq   #FALSE,d0
  move.w  d0,ifo_state(a3)   ;Image-Fader-Out aus
no_image_fader_out
  rts

  COLOR_FADER if

; ** Farbwerte in Copperliste kopieren **
; ---------------------------------------
  COPY_COLOR_TABLE_TO_COPPERLIST if,pf1,cl2,cl2_ext2_COLOR01_high1,cl2_ext2_COLOR01_low1,cl2_extension2_entry

; ** Sprites einblenden **
; ------------------------
  CNOP 0,4
sprite_fader_in
  tst.w   sprfi_state(a3)    ;Sprite-Fader-In an ?
  bne.s   no_sprite_fader_in ;Nein -> verzweige
  movem.l a4-a6,-(a7)
  move.w  sprfi_fader_angle(a3),d2 ;Fader-Winkel holen
  move.w  d2,d0
  ADDF.W  sprfi_fader_angle_speed,d0 ;nächster Fader-Winkel
  cmp.w   #sine_table_length/2,d0 ;Y-Winkel <= 180 Grad ?
  ble.s   sprfi_no_restart_fader_angle ;Ja -> verzweige
  MOVEF.W sine_table_length/2,d0 ;180 Grad
sprfi_no_restart_fader_angle
  move.w  d0,sprfi_fader_angle(a3) ;Fader-Winkel retten
  MOVEF.W sprf_colors_number*3,d6 ;Zähler
  lea     sine_table(pc),a0  ;Sinus-Tabelle
  move.l  (a0,d2.w*4),d0     ;sin(w)
  MULUF.L sprfi_fader_radius*2,d0,d1 ;y'=(yr*sin(w))/2^15
  swap    d0
  ADDF.W  sprfi_fader_center,d0 ;+ Fader-Mittelpunkt
  lea     spr_color_table+(sprf_color_table_offset*LONGWORDSIZE)(pc),a0 ;Puffer für Farbwerte
  lea     sprfi_color_table+(sprf_color_table_offset*LONGWORDSIZE)(pc),a1 ;Sollwerte
  move.w  d0,a5              ;Additions-/Subtraktionswert für Blau
  swap    d0                 ;WORDSHIFT
  clr.w   d0                 ;Bits 0-15 löschen
  move.l  d0,a2              ;Additions-/Subtraktionswert für Rot
  lsr.l   #8,d0              ;BYTESHIFT
  move.l  d0,a4              ;Additions-/Subtraktionswert für Grün
  MOVEF.W sprf_colors_number-1,d7 ;Anzahl der Farben
  bsr     if_fader_loop
  movem.l (a7)+,a4-a6
  move.w  d6,sprf_colors_counter(a3) ;Image-Fader-In fertig ?
  bne.s   no_sprite_fader_in  ;Nein -> verzweige
  moveq   #FALSE,d0
  move.w  d0,sprfi_state(a3) ;Sprite-Fader-In aus
no_sprite_fader_in
  rts

; ** Sprites ausblenden **
; ------------------------
  CNOP 0,4
sprite_fader_out
  tst.w   sprfo_state(a3)    ;Sprite-Fader-Out an ?
  bne.s   no_sprite_fader_out ;Nein -> verzweige
  movem.l a4-a6,-(a7)
  move.w  sprfo_fader_angle(a3),d2 ;Fader-Winkel holen
  move.w  d2,d0
  ADDF.W  sprfo_fader_angle_speed,d0 ;nächster Fader-Winkel
  cmp.w   #sine_table_length/2,d0 ;Y-Winkel <= 180 Grad ?
  ble.s   sprfo_no_restart_fader_angle ;Ja -> verzweige
  MOVEF.W sine_table_length/2,d0 ;180 Grad
sprfo_no_restart_fader_angle
  move.w  d0,sprfo_fader_angle(a3) ;Fader-Winkel retten
  MOVEF.W sprf_colors_number*3,d6 ;Zähler
  lea     sine_table(pc),a0  ;Sinus-Tabelle
  move.l  (a0,d2.w*4),d0     ;sin(w)
  MULUF.L sprfo_fader_radius*2,d0,d1 ;y'=(yr*sin(w))/2^15
  swap    d0
  ADDF.W  sprfo_fader_center,d0 ;+ Fader-Mittelpunkt
  lea     spr_color_table+(sprf_color_table_offset*LONGWORDSIZE)(pc),a0 ;Puffer für Farbwerte
  lea     sprfo_color_table+(sprf_color_table_offset*LONGWORDSIZE)(pc),a1 ;Sollwerte
  move.w  d0,a5              ;Additions-/Subtraktionswert für Blau
  swap    d0                 ;WORDSHIFT
  clr.w   d0                 ;Bits 0-15 löschen
  move.l  d0,a2              ;Additions-/Subtraktionswert für Rot
  lsr.l   #8,d0              ;BYTESHIFT
  move.l  d0,a4              ;Additions-/Subtraktionswert für Grün
  MOVEF.W sprf_colors_number-1,d7 ;Anzahl der Farben
  bsr     if_fader_loop
  movem.l (a7)+,a4-a6
  move.w  d6,sprf_colors_counter(a3) ;Image-Fader-Out fertig ?
  bne.s   no_sprite_fader_out ;Nein -> verzweige
  moveq   #FALSE,d0
  move.w  d0,sprfo_state(a3) ;Sprite-Fader-Out aus
no_sprite_fader_out
  rts

; ** Farbwerte in Copperliste kopieren **
; ---------------------------------------
  COPY_COLOR_TABLE_TO_COPPERLIST sprf,spr,cl1,cl1_COLOR17_high1,cl1_COLOR17_low1

; ** Bars einblenden **
; ---------------------
  CNOP 0,4
bar_fader_in
  tst.w   bfi_state(a3)      ;Bar-Fader-In an ?
  bne.s   no_bar_fader_in    ;Nein -> verzweige
  movem.l a4-a6,-(a7)
  move.w  bfi_fader_angle(a3),d2 ;Fader-Winkel holen
  move.w  d2,d0
  ADDF.W  bfi_fader_angle_speed,d0 ;nächster Fader-Winkel
  cmp.w   #sine_table_length/2,d0 ;Y-Winkel <= 180 Grad ?
  ble.s   bfi_no_restart_fader_angle ;Ja -> verzweige
  MOVEF.W sine_table_length/2,d0 ;180 Grad
bfi_no_restart_fader_angle
  move.w  d0,bfi_fader_angle(a3) ;Fader-Winkel retten
  MOVEF.W bf_colors_number*3,d6 ;Zähler
  lea     sine_table(pc),a0  ;Sinus-Tabelle
  move.l  (a0,d2.w*4),d0     ;sin(w)
  MULUF.L bfi_fader_radius*2,d0,d1 ;y'=(yr*sin(w))/2^15
  swap    d0
  ADDF.W  bfi_fader_center,d0 ;+ Fader-Mittelpunkt
  lea     bf_color_cache+(bf_color_table_offset*LONGWORDSIZE)(pc),a0 ;Puffer für Farbwerte
  lea     bfi_color_table+(bf_color_table_offset*LONGWORDSIZE)(pc),a1 ;Sollwerte
  move.w  d0,a5              ;Additions-/Subtraktionswert für Blau
  swap    d0                 ;WORDSHIFT
  clr.w   d0                 ;Bits 0-15 löschen
  move.l  d0,a2              ;Additions-/Subtraktionswert für Rot
  lsr.l   #8,d0              ;BYTESHIFT
  move.l  d0,a4              ;Additions-/Subtraktionswert für Grün
  MOVEF.W bf_colors_number-1,d7 ;Anzahl der Farben
  bsr     if_fader_loop
  movem.l (a7)+,a4-a6
  move.w  d6,bf_colors_counter(a3) ;Image-Fader-In fertig ?
  bne.s   no_bar_fader_in  ;Nein -> verzweige
  moveq   #FALSE,d0
  move.w  d0,bfi_state(a3)   ;Bar-Fader-In aus
no_bar_fader_in
  rts

; ** Bars ausblenden **
; ---------------------
  CNOP 0,4
bar_fader_out
  tst.w   bfo_state(a3)      ;Bar-Fader-Out an ?
  bne.s   no_bar_fader_out   ;Nein -> verzweige
  movem.l a4-a6,-(a7)
  move.w  bfo_fader_angle(a3),d2 ;Fader-Winkel holen
  move.w  d2,d0
  ADDF.W  bfo_fader_angle_speed,d0 ;nächster Fader-Winkel
  cmp.w   #sine_table_length/2,d0 ;Y-Winkel <= 180 Grad ?
  ble.s   bfo_no_restart_fader_angle ;Ja -> verzweige
  MOVEF.W sine_table_length/2,d0 ;180 Grad
bfo_no_restart_fader_angle
  move.w  d0,bfo_fader_angle(a3) ;Fader-Winkel retten
  MOVEF.W bf_colors_number*3,d6 ;Zähler
  lea     sine_table(pc),a0  ;Sinus-Tabelle
  move.l  (a0,d2.w*4),d0     ;sin(w)
  MULUF.L bfo_fader_radius*2,d0,d1 ;y'=(yr*sin(w))/2^15
  swap    d0
  ADDF.W  bfo_fader_center,d0 ;+ Fader-Mittelpunkt
  lea     bf_color_cache+(bf_color_table_offset*LONGWORDSIZE)(pc),a0 ;Puffer für Farbwerte
  lea     bfo_color_table+(bf_color_table_offset*LONGWORDSIZE)(pc),a1 ;Sollwerte
  move.w  d0,a5              ;Additions-/Subtraktionswert für Blau
  swap    d0                 ;WORDSHIFT
  clr.w   d0                 ;Bits 0-15 löschen
  move.l  d0,a2              ;Additions-/Subtraktionswert für Rot
  lsr.l   #8,d0              ;BYTESHIFT
  move.l  d0,a4              ;Additions-/Subtraktionswert für Grün
  MOVEF.W bf_colors_number-1,d7 ;Anzahl der Farben
  bsr     if_fader_loop
  movem.l (a7)+,a4-a6
  move.w  d6,bf_colors_counter(a3) ;Image-Fader-Out fertig ?
  bne.s   no_bar_fader_out   ;Nein -> verzweige
  moveq   #FALSE,d0
  move.w  d0,bfo_state(a3)   ;Bar-Fader-Out aus
no_bar_fader_out
  rts

; ** Farbwerte umwandeln **
; -------------------------
  CNOP 0,4
bf_convert_color_table
  tst.w   bf_convert_colors_state(a3)  ;Kopieren der Farbwerte beendet ?
  bne.s   bf_no_convert_color_table ;Ja -> verzweige
bf_convert_color_table2
  move.w  #$0f0f,d3          ;Maske für RGB-Nibbles
  lea     bf_color_cache(pc),a0 ;Quelle: Puffer für Farbwerte
  lea     scs_bar_color_table+(bf_color_table_offset*LONGWORDSIZE)(pc),a1 ;Ziel: Bar-Farbtabelle
  lea     scs_bar_color_table+(bf_color_table_offset*LONGWORDSIZE)+(bf_colors_number*LONGWORDSIZE)(pc),a2 ;Ziel: Ende der Bar-Farbtabelle
  MOVEF.W (bf_colors_number/2)-1,d7 ;Anzahl der Farben
bf_convert_color_table_loop
  move.l  (a0)+,d0           ;RGB8-Farbwert
  move.l  d0,d2              
  RGB8_TO_RGB4HI d0,d1,d3
  move.w  d0,(a1)+           ;COLORxx High-Bits
  RGB8_TO_RGB4LO d2,d1,d3
  move.w  d2,(a1)+           ;Low-Bits COLORxx
  move.w  d2,-(a2)           ;Low-Bits COLORxx
  move.w  d0,-(a2)           ;COLORxx High-Bits
  dbf     d7,bf_convert_color_table_loop
  tst.w   bf_colors_counter(a3) ;Fading beendet ?
  bne.s   bf_no_convert_color_table ;Nein -> verzweige
  moveq   #FALSE,d0
  move.w  d0,bf_convert_colors_state(a3) ;Konvertieren beendet
bf_no_convert_color_table
  rts


; ** Mouse-Handler **
; -------------------
  CNOP 0,4
mouse_handler
  btst    #CIAB_GAMEPORT0,CIAPRA(a4) ;Linke Maustaste gedrückt ?
  beq.s   mh_quit            ;Ja -> verzweige
  btst    #POTINPB_DATLY,POTINP-DMACONR(a6) ;Rechte Maustaste gedrückt ?
  beq.s   mh_start_ship_animation
  rts
  CNOP 0,4
mh_quit
  moveq   #FALSE,d1
  move.w  d1,pt_trigger_fx_state(a3) ;FX-Abfrage aus
  moveq   #TRUE,d0
  tst.w   scs_state(a3)      ;Scrolltext aktiv ?
  beq.s   mh_quit_with_scrolltext ;Ja -> verzweige
mh_quit_without_scrolltext
  move.w  d0,pt_fade_out_music_state(a3) ;Musik ausfaden
  move.w  #if_colors_number*3,if_colors_counter(a3)
  move.w  d0,ifo_state(a3)   ;Image-Fader-Out an
  move.w  d0,if_copy_colors_state(a3) ;Kopieren der Farben an
  tst.w   ifi_state(a3)      ;Image-Fader-In aktiv ?
  bne.s   mh_skip1           ;Nein -> verzweige
  move.w  d1,ifi_state(a3)   ;Image-Fader-In aus
mh_skip1
  move.w  #sprf_colors_number*3,sprf_colors_counter(a3)
  move.w  d0,sprfo_state(a3)   ;Sprite-Fader-Out an
  move.w  d0,sprf_copy_colors_state(a3) ;Kopieren der Farben an
  tst.w   sprfi_state(a3)    ;Sprite-Fader-In aktiv ?
  bne.s   mh_skip2           ;Nein -> verzweige
  move.w  d1,sprfi_state(a3) ;Sprite-Fader-In aus
mh_skip2
  move.w  #bf_colors_number*3,bf_colors_counter(a3)
  move.w  d0,bf_convert_colors_state(a3) ;Konvertieren der Farben an
  move.w  d0,bfo_state(a3)   ;Bar-Fader-Out an
  tst.w   bfi_state(a3)      ;Bar-Fader-In aktiv ?
  bne.s   mh_skip3           ;Nein -> verzweige
  move.w  d1,bfi_state(a3)   ;Bar-Fader-In aus
mh_skip3
  rts
  CNOP 0,4
mh_quit_with_scrolltext
  move.w  #scs_stop_text-scs_text,scs_text_table_start(a3) ;Scrolltext beenden
  move.w  d0,quit_state(a3)  ;Intro soll nach Text-Stopp beendet werden
  rts
  CNOP 0,4
mh_start_ship_animation
  tst.w   bfi_state(a3)      ;Werden die Bars noch eingeblendet ?
  beq.s   mh_no_start_ship_animation_left ;Ja -> verzweige
  tst.w   pt_fade_out_music_state(a3) ;Wird Modul bereits ausgeblendet ?
  beq.s   mh_no_start_ship_animation_left ;Ja -> verzweige
  tst.w   msl_state(a3)      ;Ist die Animation nach links aktiv ?
  beq.s   mh_no_start_ship_animation_left ;Ja -> verzweige
  tst.w   msr_state(a3)      ;Ist die Animation nach rechts aktiv ?
  beq.s   mh_no_start_ship_animation_left ;Ja -> verzweige
  bsr     msl_copy_bitmaps
  clr.w   msl_state(a3)      ;Animation nach links starten
  move.w  #sine_table_length2/4,msl_x_angle(a3) ;X-Winkel auf 90 Grad zurücksetzen
mh_no_start_ship_animation_left
  rts


; ## Interrupt-Routinen ##
; ------------------------
  
  INCLUDE "int-autovectors-handlers.i"

  IFEQ pt_ciatiming
; ** CIA-B timer A interrupt server **
; ------------------------------------
  CNOP 0,4
CIAB_TA_int_server
  ENDC

  IFNE pt_ciatiming
; ** Vertical blank interrupt server **
; -------------------------------------
  CNOP 0,4
VERTB_int_server
  ENDC

  IFEQ pt_music_fader
    bsr.s   pt_fade_out_music
    bra.s   pt_PlayMusic

; ** Musik ausblenden **
; ----------------------
    PT_FADE_OUT fx_state

    CNOP 0,4
  ENDC

; ** PT-replay routine **
; -----------------------
  IFD pt_v2.3a
    PT2_REPLAY pt_trigger_fx
  ENDC
  IFD pt_v3.0b
    PT3_REPLAY pt_trigger_fx
  ENDC

;--> 8xy "Not used/custom" <--
  CNOP 0,4
pt_trigger_fx
  tst.w   pt_trigger_fx_state(a3) ;Check enabled?
  bne.s   pt_no_trigger_fx   ;No -> skip
  move.b  n_cmdlo(a2),d0     ;Get command data x = Effekt y = TRUE/FALSE
  beq.s   pt_start_intro
  cmp.b   #$10,d0
  beq.s   pt_increase_x_radius_angle_step
  cmp.b   #$20,d0
  beq.s   pt_start_calculate_z_planes_step
  cmp.b   #$30,d0
  beq.s   pt_start_scrolltext
pt_no_trigger_fx
  rts
  CNOP 0,4
pt_start_intro
  move.w  #if_colors_number*3,if_colors_counter(a3)
  moveq   #TRUE,d0
  move.w  d0,ifi_state(a3)   ;Image-Fader-In an
  move.w  d0,if_copy_colors_state(a3) ;Kopieren der Farben an

  move.w  #sprf_colors_number*3,sprf_colors_counter(a3)
  move.w  d0,sprfi_state(a3) ;Sprite-Fader-In an
  move.w  d0,sprf_copy_colors_state(a3) ;Kopieren der Farben an

  move.w  #bf_colors_number*3,bf_colors_counter(a3)
  move.w  d0,bfi_state(a3)   ;Bar-Fader-In an
  move.w  d0,bf_convert_colors_state(a3) ;Konvertieren der Farben an
  rts
  CNOP 0,4
pt_start_calculate_z_planes_step
  clr.w   hcs_calculate_planes_x_step_state(a3) ;Berechnung an
  rts
  CNOP 0,4
pt_increase_x_radius_angle_step
  addq.w  #1,hsi_variable_x_radius_angle_step(a3) ;Schrittweite erhöhen
  rts
  CNOP 0,4
pt_start_scrolltext
  moveq   #TRUE,d0
  move.w  d0,scs_state(a3)   ;Scrolltext an
  move.w  d0,scs_text_table_start(a3) ;Textanfang
  rts

; ** CIA-B Timer B interrupt server **
  CNOP 0,4
CIAB_TB_int_server
  PT_TIMER_INTERRUPT_SERVER

; ** Level-6-Interrupt-Server **
; ------------------------------
  CNOP 0,4
EXTER_int_server
  rts

; ** Level-7-Interrupt-Server **
; ------------------------------
  CNOP 0,4
NMI_int_server
  rts


; ** Timer stoppen **
; -------------------

  INCLUDE "continuous-timers-stop.i"


; ## System wieder in Ausganszustand zurücksetzen ##
; --------------------------------------------------

  INCLUDE "sys-return.i"


; ## Hilfsroutinen ##
; -------------------

  INCLUDE "help-routines.i"


; ## Speicherstellen für Tabellen und Strukturen ##
; -------------------------------------------------

  INCLUDE "sys-structures.i"

; ** Farben des ersten Playfields **
; ----------------------------------
  CNOP 0,4
pf1_color_table
  DC.L COLOR00BITS

vp1_pf1_color_table
  REPT vp1_pf1_colors_number
    DC.L COLOR00BITS
  ENDR

vp2_pf1_color_table
  DC.L COLOR00BITS

vp2_pf2_color_table
  DC.L COLOR00BITS

; ** Farben der Sprites **
; ------------------------
spr_color_table
  REPT spr_colors_number
    DC.L COLOR00BITS
  ENDR
vp2_spr_color_table
  INCLUDE "Daten:Asm-Sources.AGA/CoolCorkscrew/colortables/64x32x16-Spaceship.ct"

; ** Adressen der Sprites **
; --------------------------
spr_pointers_construction
  DS.L spr_number

spr_pointers_display
  DS.L spr_number

; ** Sinus / Cosinustabelle **
; ----------------------------
sine_table
  INCLUDE "sine-table-256x32.i"

  CNOP 0,2
sine_table_512
  INCLUDE "sine-table-512x16.i"

; **** PT-Replay ****
; ** Tables for effect commands **
; --------------------------------
; ** "Invert Loop" **
  INCLUDE "music-tracker/pt-invert-table.i"

; ** "Vibrato/Tremolo" **
  INCLUDE "music-tracker/pt-vibrato-tremolo-table.i"

; ** "Arpeggio/Tone Portamento" **
  IFD pt_v2.3a
    INCLUDE "music-tracker/pt2-period-table.i"
  ENDC
  IFD pt_v3.0b
    INCLUDE "music-tracker/pt3-period-table.i"
  ENDC

; ** Temporary channel structures **
; ----------------------------------
  INCLUDE "music-tracker/pt-temp-channel-data-tables.i"

; ** Pointers to samples **
; -------------------------
  INCLUDE "music-tracker/pt-sample-starts-table.i"

; ** Pointers to priod tables for different tuning **
; ---------------------------------------------------
  INCLUDE "music-tracker/pt-finetune-starts-table.i"

; **** Horiz-Scaling-Image ****
; ** Tabelle mit Shift-Werten **
; ------------------------------
hsi_shift_table
  DS.B hsi_shift_values_number

; ** Tabelle mit Radiuswerten für positive und negative Sinuskurve **
; -------------------------------------------------------------------
  CNOP 0,2
hsi_radius_table
  DS.W hsi_lines_number

; ** Tabelle mit Werten für das BPLCON1-Register **
; -------------------------------------------------
hsi_BPLCON1_table
  DS.W cl2_display_width*hsi_lines_number
  DC.W vp1_BPLCON1BITS

; **** Horiz-Characterscrolling ****
; ** X-Koordinaten der einzelnen Buchstaben **
; --------------------------------------------
  CNOP 0,2
hcs_objects_x_coordinates
  DS.W hcs_objects_number

; **** Single-Corkscrew-Scroll ****
  CNOP 0,4
scs_color_gradient_front
  INCLUDE "Daten:Asm-Sources.AGA/CoolCorkscrew/colortables/2x32-Colorgradient-Blue.hlct"

scs_color_gradient_back
  INCLUDE "Daten:Asm-Sources.AGA/CoolCorkscrew/colortables/2x32-Colorgradient-Orchid.hlct"

scs_color_gradient_outline
  INCLUDE "Daten:Asm-Sources.AGA/CoolCorkscrew/colortables/2x32-Colorgradient-Grey.hlct"

; ** Center-Bar **
  IFEQ scs_center_bar
scs_bar_color_table
    REPT sb_bar_height
      DC.L COLOR00BITS
    ENDR
  ENDC

; ** ASCII-Zeichen des Fonts **
; -----------------------------
scs_ASCII
  DC.B "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?-'():\/# "
scs_ASCII_end
  EVEN

; ** Offsets der einzelnen Chars **
; ---------------------------------
  CNOP 0,2
scs_characters_offsets
  DS.W scs_ASCII_end-scs_ASCII
  
; ** Shiftwerte für X-Shift **
; ----------------------------
  IFEQ scs_pipe_effect
scs_pipe_shift_x_table
    DS.W scs_roller_y_radius*2
  ENDC

; **** Sine-Bars 3.6 ****
; ** Tabelle mit Y+Z-Koordinaten der Stangen **
; ---------------------------------------------
sb36_yz_coordinates
  DS.W sb36_bars_number*2

; **** Image-Fader ****
; ** Zielfarbwerte für Image-Fader-In **
; --------------------------------------
  CNOP 0,4
ifi_color_table
  INCLUDE "Daten:Asm-Sources.AGA/CoolCorkscrew/colortables/256x30x16-Resistance.ct"

; ** Zielfarbwerte für Image-Fader-Out **
; ---------------------------------------
ifo_color_table
  REPT vp1_pf1_colors_number
    DC.L COLOR00BITS
  ENDR

; **** Sprite-Fader ****
; ** Zielfarbwerte für Sprite-Fader-In **
; ---------------------------------------
  CNOP 0,4
sprfi_color_table
  INCLUDE "Daten:Asm-Sources.AGA/CoolCorkscrew/colortables/16x15x16-3D-RSE.ct"

; ** Zielfarbwerte für Sprite-Fader-Out **
; ----------------------------------------
sprfo_color_table
  REPT spr_colors_number
    DC.L COLOR00BITS
  ENDR

; **** Bar-Fader ****
; ** Zielfarbwerte für Bar-Fader-In **
; ------------------------------------
  CNOP 0,4
bfi_color_table
  INCLUDE "Daten:Asm-Sources.AGA/CoolCorkscrew/colortables/5-Colorgradient-Orchid.ct"

; ** Zielfarbwerte für Bar-Fader-Out **
; -------------------------------------                                           p
bfo_color_table
  REPT sb_bar_height
    DC.L COLOR00BITS
  ENDR

; ** Puffer für Farbwerte **
; --------------------------
bf_color_cache
  REPT sb_bar_height
    DC.L COLOR00BITS
  ENDR


; ## Speicherstellen allgemein ##
; -------------------------------

  INCLUDE "sys-variables.i"


; ## Speicherstellen für Namen ##
; -------------------------------

  INCLUDE "sys-names.i"


; ## Speicherstellen für Texte ##
; -------------------------------

  INCLUDE "error-texts.i"

; ** Programmversion für Version-Befehl **
; ----------------------------------------
prg_version DC.B "$VER: RSE-CoolCorkscrew 1.2 (2.6.24)",TRUE
  EVEN

; **** Single-Corkscrew-Scroll ****
; ** Text für Laufschrift **
; --------------------------
scs_text
  DC.B "RESISTANCE PRESENTS A NEW INTRO CALLED          COOL¹             CORKSCREW           "

  DC.B "THIS IS OUR CONTRIBUTION TO DEADLINE 2024           "

  DC.B "PRESS RMB TO START SPACESHIP               "

  DC.B "²GREETINGS FLY TO           "
  DC.B "# DESIRE #         "
  DC.B "# EPHIDRENA #         "
  DC.B "# FOCUS DESIGN #         "
  DC.B "# GHOSTOWN #         "
  DC.B "# NAH-KOLOR #         "
  DC.B "# PLANET JAZZ #         "
  DC.B "# SOFTWARE FAILURE #         "
  DC.B "# TEK #         "
  DC.B "# WANTED TEAM #           "

  DC.B "¹THE CREDITS          "
  DC.B "CODING AND MUSIC          "
  DC.B "DISSIDENT           "
  DC.B "GRAPHICS          "
  DC.B "  GRASS            "

scs_stop_text
  REPT ((scs_text_characters_number)/(scs_origin_character_x_size/scs_text_character_x_size))-2
    DC.B " "
  ENDR
  DC.B " "
  EVEN


; ## Audiodaten nachladen ##
; --------------------------

; **** PT-Replay ****
  IFEQ pt_split_module
pt_auddata SECTION audio,DATA
    INCBIN "Daten:Asm-Sources.AGA/CoolCorkscrew/modules/mod.RetroDisco(remix).song"
pt_audsmps SECTION audio2,DATA_C
    INCBIN "Daten:Asm-Sources.AGA/CoolCorkscrew/modules/mod.RetroDisco(remix).smps"
  ELSE
pt_auddata SECTION audio,DATA_C
    INCBIN "Daten:Asm-Sources.AGA/CoolCorkscrew/modules/mod.RetroDisco(remix)"
  ENDC


; ## Grafikdaten nachladen ##
; ---------------------------

; **** Background-Image ****
bg_image_data SECTION bg_gfx,DATA
  INCBIN "Daten:Asm-Sources.AGA/CoolCorkscrew/graphics/256x30x16-Resistance.rawblit"

; **** Horiz-Charactersrolling ****
hcs_image_data SECTION hcs_gfx,DATA
  INCBIN "Daten:Asm-Sources.AGA/CoolCorkscrew/graphics/16x15x16-3D-RSE.rawblit"

; **** Single-Corkscrew-Scroll ****
scs_image_data SECTION scs_gfx,DATA_C
  INCBIN "Daten:Asm-Sources.AGA/CoolCorkscrew/fonts/32x32x4-Font.rawblit"

; **** Spaceship-Image ****
msl_image_data SECTION msl_gfx,DATA
  INCBIN "Daten:Asm-Sources.AGA/CoolCorkscrew/graphics/64x32x16-Spaceship-Left.rawblit"

msr_image_data SECTION msr_gfx,DATA
  INCBIN "Daten:Asm-Sources.AGA/CoolCorkscrew/graphics/64x32x16-Spaceship-Right.rawblit"

  END
