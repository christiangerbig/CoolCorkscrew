; Requirements
; 68020+
; AGA PAL
; 3.0+


; History/Changes

; V.1.0 Beta
; - 1st release

; V.1.1 Beta
; - Code optimized
; - Text changed

; V.1.2 Beta
; - Spaceship speed 50 % reduced. A 2nd sine table with 512 entries is used
; - Sprite usage changed to avoid display glitches at left border
; - SPR0/1 Spaceship
; - SRP2-7 Character scrolling

; V.1.3 Beta
; - Spaceship movement from right to left and back
; - SPR0-5 Character scrolling
; - SPR0/1 (re-use) Spaceship pointing left
; - SPR2/3 (re-use) Spaceship pointing right

; V1.4 Beta
; - Grass' RSE gfx included
; - Convert-Color-Table of bar alrfeady called via inits to get the proper
;  bar colors at the beginnning

; V.1.5 Beta
; - Grass' revised logo ("C" version) included

; V1.6 Beta
; - Grass' font included
; - Color gradients of bar and scrolltext adapted

; V1.7 Beta
; - Grass' spaceship included

; V.1.8 Beta
; - Grass' icon included
; - WB start enabled
; - WB fader enabled

; V.1.9 Beta
; - Scrolltext changed to match the music

; V.1.0
; - Credits changedc
; - Code optimizedc
; - Mouse-Handler: Out-Fader stops In-Fader
; - Lunix' icon included
; - Spaceship animation: If the user triggers the spaceship a flight to right
;                      is aborted and the spaceship gfx are changed during
;                      horizontal blank. Only SPR0 & SPR1 are used.
; - adf file created
; - Fader optimized

; V.1.1
; - Credits changed again, because luNix wished to be removed.
; - Icon: at offset $3a und $3e $80000000 to avoid a fixed position
; - revised include files used
; - Move-Spaceship routine optimized

; V.1.2
; - Fader-Code optimized

; V.1.3
; - Spaceship animation handler changed: The user can only trigger the spaceship
;   if the scrolltext is active and the intro is not about to end.
; - New 8xy command: Ship animation triggered by 840 command

; V.1.4
; - revised include files used
; - Code slightly revised


; PT 8xy command
; 800	Start intro
; 810	Increase variable x_radius_angle_step
; 820	Start to calculate z_planes_step
; 830	Start scrolltext
; 840	Enable ship animation


; Execution time 68020: 279 raster lines


	MC68040


	INCDIR "include3.5:"

	INCLUDE "exec/exec.i"
	INCLUDE "exec/exec_lib.i"

	INCLUDE "dos/dos.i"
	INCLUDE "dos/dos_lib.i"
	INCLUDE "dos/dosextens.i"

	INCLUDE "graphics/gfxbase.i"
	INCLUDE "graphics/graphics_lib.i"
	INCLUDE "graphics/videocontrol.i"

	INCLUDE "intuition/intuition.i"
	INCLUDE "intuition/intuition_lib.i"

	INCLUDE "libraries/any_lib.i"

	INCLUDE "resources/cia_lib.i"

	INCLUDE "hardware/adkbits.i"
	INCLUDE "hardware/blit.i"
	INCLUDE "hardware/cia.i"
	INCLUDE "hardware/custom.i"
	INCLUDE "hardware/dmabits.i"
	INCLUDE "hardware/intbits.i"


PROTRACKER_VERSION_3		SET 1


	INCDIR "custom-includes-aga:"


	INCLUDE "macros.i"


	INCLUDE "equals.i"

requires_030_cpu		EQU FALSE
requires_040_cpu		EQU FALSE
requires_060_cpu		EQU FALSE
requires_fast_memory		EQU FALSE
requires_multiscan_monitor	EQU FALSE

workbench_start_enabled		EQU FALSE
screen_fader_enabled		EQU TRUE
text_output_enabled		EQU FALSE

; PT-Replay
pt_ciatiming_enabled		EQU TRUE
pt_usedfx			EQU %1111110101011010
pt_usedefx			EQU %0000110000000000
pt_mute_enabled			EQU FALSE
pt_music_fader_enabled		EQU TRUE
pt_fade_out_delay		EQU 2	; Ticks
pt_split_module_enabled		EQU TRUE
pt_track_notes_played_enabled	EQU FALSE
pt_track_volumes_enabled	EQU FALSE
pt_track_periods_enabled	EQU FALSE
pt_track_data_enabled		EQU FALSE
pt_metronome_enabled		EQU FALSE
pt_metrochanbits		EQU pt_metrochan1
pt_metrospeedbits		EQU pt_metrospeed4th

; Horiz-Character-Scrolling
hcs_quick_x_max_restart		EQU FALSE

; Single-Corkscrew-Scroll 
scs_pipe_effect			EQU TRUE
scs_center_bar			EQU TRUE

dma_bits			EQU DMAF_SPRITE|DMAF_BLITTER|DMAF_COPPER|DMAF_RASTER|DMAF_MASTER|DMAF_SETCLR

	IFEQ pt_ciatiming_enabled
intena_bits			EQU INTF_EXTER|INTF_INTEN|INTF_SETCLR
	ELSE
intena_bits			EQU INTF_VERTB|INTF_EXTER|INTF_INTEN|INTF_SETCLR
	ENDC

ciaa_icr_bits			EQU CIAICRF_SETCLR
	IFEQ pt_ciatiming_enabled
ciab_icr_bits			EQU CIAICRF_TA|CIAICRF_TB|CIAICRF_SETCLR
	ELSE
ciab_icr_bits			EQU CIAICRF_TB|CIAICRF_SETCLR
	ENDC

copcon_bits			EQU 0

pf1_x_size1			EQU 0
pf1_y_size1			EQU 0
pf1_depth1			EQU 0
pf1_x_size2			EQU 0
pf1_y_size2			EQU 0
pf1_depth2			EQU 0
pf1_x_size3			EQU 0
pf1_y_size3			EQU 0
pf1_depth3			EQU 0
pf1_colors_number		EQU 0

pf2_x_size1			EQU 0
pf2_y_size1			EQU 0
pf2_depth1			EQU 0
pf2_x_size2			EQU 0
pf2_y_size2			EQU 0
pf2_depth2			EQU 0
pf2_x_size3			EQU 0
pf2_y_size3			EQU 0
pf2_depth3			EQU 0
pf2_colors_number		EQU 0
pf_colors_number		EQU pf1_colors_number+pf2_colors_number
pf_depth			EQU pf1_depth3+pf2_depth3

pf_extra_number			EQU 2
extra_pf1_x_size		EQU 320
extra_pf1_y_size		EQU 30
extra_pf1_depth			EQU 4
extra_pf2_x_size		EQU 448
extra_pf2_y_size		EQU (64*2)+2 ; vertical scroll speed = 2
extra_pf2_depth			EQU 2

spr_number			EQU 8
spr_x_size1			EQU 64
spr_x_size2			EQU 64
spr_depth			EQU 2
spr_colors_number		EQU 16
spr_odd_color_table_select	EQU 1
spr_even_color_table_select	EQU 1
vp2_spr_odd_color_table_select	EQU 2
vp2_spr_even_color_table_select	EQU 2
spr_used_number			EQU 8
spr_swap_number			EQU 8

	IFD PROTRACKER_VERSION_2 
audio_memory_size		EQU 0
	ENDC
	IFD PROTRACKER_VERSION_3
audio_memory_size		EQU 1*WORD_SIZE
	ENDC

disk_memory_size		EQU 0

extra_memory_size		EQU 0

chip_memory_size		EQU 0
	IFEQ pt_ciatiming_enabled
ciab_cra_bits			EQU CIACRBF_LOAD
	ENDC
ciab_crb_bits			EQU CIACRBF_LOAD|CIACRBF_RUNMODE ; oneshot mode
ciaa_ta_time			EQU 0
ciaa_tb_time			EQU 0
	IFEQ pt_ciatiming_enabled
ciab_ta_time			EQU 14187 ; = 0.709379 MHz * [20000 µs = 50 Hz duration for one frame on a PAL machine]
;ciab_ta_time			EQU 14318 ; = 0.715909 MHz * [20000 µs = 50 Hz duration for one frame on a NTSC machine]
	ELSE
ciab_ta_time			EQU 0
	ENDC
ciab_tb_time			EQU 362	; = 0.709379 MHz * [511.43 µs = Lowest note period C1 with Tuning=-8 * 2 / PAL clock constant = 907*2/3546895 ticks per second]
					; = 0.715909 MHz * [506.76 µs = Lowest note period C1 with Tuning=-8 * 2 / NTSC clock constant = 907*2/3579545 ticks per second]
ciaa_ta_continuous_enabled	EQU FALSE
ciaa_tb_continuous_enabled	EQU FALSE
	IFEQ pt_ciatiming_enabled
ciab_ta_continuous_enabled	EQU TRUE
	ELSE
ciab_ta_continuous_enabled	EQU FALSE
	ENDC
ciab_tb_continuous_enabled	EQU FALSE

beam_position			EQU $133


MINROW				EQU VSTART_256_LINES

display_window_hstart		EQU HSTART_320_PIXEL
display_window_vstart		EQU MINROW
display_window_hstop		EQU HSTOP_320_PIXEL
display_window_vstop		EQU VSTOP_256_LINES

spr_pixel_per_datafetch		EQU 64	; 4x

; Vertical-Blank 1
vb1_lines_number		EQU (192-extra_pf1_y_size)/2

vb1_vstart			EQU MINROW
vb1_vstop			EQU MINROW+vb1_lines_number

; Viewport 1
vp1_pixel_per_line		EQU 320
vp1_visible_pixels_number	EQU 320
vp1_visible_lines_number	EQU 30

vp1_vstart			EQU MINROW+((192-vp1_visible_lines_number)/2)
vp1_vstop			EQU vp1_VSTART+vp1_visible_lines_number

vp1_pf_pixel_per_datafetch	EQU 64	; 4x

vp1_pf1_colors_number		EQU 16

; Vertical-Blank 2
vb2_lines_number		EQU (192-extra_pf1_y_size)/2

vb2_vstart			EQU vp1_VSTOP
vb2_vstop			EQU vp1_VSTOP+vb2_lines_number

; Viewport 2
vp2_pixel_per_line		EQU 320
vp2_visible_pixels_number	EQU 320
vp2_visible_lines_number	EQU 64

vp2_vstart			EQU vb2_VSTOP
vp2_vstop			EQU vp2_VSTART+vp2_visible_lines_number

vp2_pf_pixel_per_datafetch	EQU 64	; 4x

vp2_pf1_colors_number		EQU 4

; Viewport 1
; Playfield 1
extra_pf1_plane_width		EQU extra_pf1_x_size/8

; Viewport 2 
; Playfield 1 
extra_pf2_plane_width		EQU extra_pf2_x_size/8

; Viewport 1 
vp1_data_fetch_width		EQU vp1_pixel_per_line/8
vp1_pf1_plane_moduli		EQU (extra_pf1_plane_width*(extra_pf1_depth-1))+extra_pf1_plane_width-vp1_data_fetch_width

; Viewport 2
vp2_data_fetch_width		EQU vp2_pixel_per_line/8
vp2_pf1_plane_moduli		EQU (extra_pf2_plane_width*(extra_pf2_depth-1))+extra_pf2_plane_width-vp2_data_fetch_width
vp2_pf2_plane_moduli		EQU -((extra_pf2_plane_width*(extra_pf2_depth-1))+(extra_pf2_plane_width-vp2_data_fetch_width)+(2*vp2_data_fetch_width))

; View 
diwstrt_bits			EQU ((display_window_vstart&$ff)*DIWSTRTF_V0)|(display_window_hstart&$ff)
diwstop_bits			EQU ((display_window_vstop&$ff)*DIWSTOPF_V0)|(display_window_hstop&$ff)
bplcon0_bits			EQU BPLCON0F_ECSENA|((pf_depth>>3)*BPLCON0F_BPU3)|(BPLCON0F_COLOR)|((pf_depth&$07)*BPLCON0F_BPU0)
bplcon3_bits1			EQU BPLCON3F_SPRES0
bplcon3_bits2			EQU bplcon3_bits1|BPLCON3F_LOCT
bplcon4_bits			EQU (BPLCON4F_OSPRM4*spr_odd_color_table_select)|(BPLCON4F_ESPRM4*spr_even_color_table_select)
diwhigh_bits			EQU (((display_window_hstop&$100)>>8)*DIWHIGHF_HSTOP8)|(((display_window_vstop&$700)>>8)*DIWHIGHF_VSTOP8)|(((display_window_hstart&$100)>>8)*DIWHIGHF_HSTART8)|((display_window_vstart&$700)>>8)
fmode_bits			EQU FMODEF_SPR32|FMODEF_SPAGEM
color00_bits			EQU $0e111d
color00_high_bits		EQU $011
color00_low_bits		EQU $e1d

; Viewport 1
vp1_ddfstrt_bits		EQU DDFSTART_320_PIXEL
vp1_ddfstop_bits		EQU DDFSTOP_320_PIXEL_4X
vp1_bplcon0_bits1		EQU BPLCON0F_ECSENA|((extra_pf1_depth>>3)*BPLCON0F_BPU3)|(BPLCON0F_COLOR)|((extra_pf1_depth&$07)*BPLCON0F_BPU0)
vp1_bplcon0_bits2		EQU BPLCON0F_ECSENA|BPLCON0F_COLOR
vp1_bplcon1_bits		EQU 0
vp1_bplcon2_bits		EQU 0
vp1_bplcon3_bits1		EQU bplcon3_bits1
vp1_bplcon3_bits2		EQU vp1_bplcon3_bits1|BPLCON3F_LOCT
vp1_bplcon4_bits		EQU bplcon4_bits
vp1_fmode_bits			EQU fmode_bits|FMODEF_BPL32|FMODEF_BPAGEM
vp1_color00_bits		EQU color00_bits

; Viewport 2
vp2_ddfstrt_bits		EQU DDFSTART_320_PIXEL
vp2_ddfstop_bits		EQU DDFSTOP_320_PIXEL_4X
vp2_bplcon0_bits1		EQU BPLCON0F_ECSENA|(((extra_pf2_depth*2)>>3)*BPLCON0F_BPU3)|(BPLCON0F_COLOR)|BPLCON0F_DPF|(((extra_pf2_depth*2)&$07)*BPLCON0F_BPU0)
vp2_bplcon0_bits2		EQU BPLCON0F_ECSENA|BPLCON0F_COLOR
vp2_bplcon1_bits		EQU 0
vp2_bplcon2_bits		EQU BPLCON2F_PF2P2
vp2_bplcon3_bits1		EQU bplcon3_bits1|BPLCON3F_PF2OF1
vp2_bplcon3_bits2		EQU vp2_bplcon3_bits1|BPLCON3F_LOCT
vp2_bplcon4_bits		EQU (BPLCON4F_OSPRM4*vp2_spr_odd_color_table_select)|(BPLCON4F_ESPRM4*vp2_spr_even_color_table_select)
vp2_fmode_bits			EQU fmode_bits|FMODEF_BPL32|FMODEF_BPAGEM
vp2_color00_bits		EQU color00_bits

cl2_display_x_size		EQU 320
cl2_display_width		EQU cl2_display_x_size/8
cl2_display_y_size		EQU vp1_visible_lines_number

; Vertical Blank	1
cl2_vb1_hstart			EQU display_window_hstart-(1*CMOVE_SLOT_PERIOD)
cl2_vb1_vstart			EQU vb1_VSTART

; Viewport 1
cl2_vp1_hstart			EQU display_window_hstart+(1*CMOVE_SLOT_PERIOD)
cl2_vp1_vstart			EQU vp1_VSTART

; Vertical-Blank 2
cl2_vb2_hstart			EQU display_window_hstart-(1*CMOVE_SLOT_PERIOD)
cl2_vb2_vstart			EQU vb2_VSTART

; Viewport 2
cl2_vp2_hstart			EQU $00
cl2_vp2_vstart			EQU vp2_VSTART

; Copper-Interrupt
cl2_hstart			EQU $00
cl2_vstart			EQU beam_position&$ff

sine_table_length1		EQU 256
sine_table_length2		EQU 512

; Background-Image 
bg_image_x_size			EQU 256
bg_image_plane_width		EQU bg_image_x_size/8
bg_image_y_size			EQU 30
bg_image_depth			EQU 4
bg_image_x_position		EQU 16
bg_image_y_position		EQU 0

; Horiz-Scaling-Image 
hsi_shift_values_number		EQU 32
hsi_lines_number		EQU bg_image_y_size
hsi_x_radius			EQU 8
hsi_x_radius_angle_speed	EQU 5
hsi_x_angle_step		EQU 4

; Horiz-Characterscrolling 
hcs_image_x_size		EQU 16
hcs_image_plane_width		EQU hcs_image_x_size/8
hcs_image_y_size		EQU 15
hcs_image_depth			EQU 4

hcs_used_sprites_number		EQU 6
hcs_reused_sprites_number	EQU 192/(hcs_image_y_size+1)*(hcs_used_sprites_number/2)

	IFEQ hcs_quick_x_max_restart
hcs_random_x_max		EQU (512*SHIRES_PIXEL_FACTOR)-1
hcs_x_min			EQU 0
hcs_x_max			EQU hcs_random_x_max
	ELSE
hcs_random_x_max		EQU (display_window_hstop-display_window_hstart)*SHIRES_PIXEL_FACTOR
hcs_x_min			EQU (display_window_hstart-hcs_image_x_size)*SHIRES_PIXEL_FACTOR
hcs_x_max			EQU display_window_hstop*SHIRES_PIXEL_FACTOR
hcs_horiz_restart		EQU ((display_window_hstop-display_window_hstart)+hcs_image_x_size)*SHIRES_PIXEL_FACTOR
	ENDC

hcs_z_planes_number		EQU 3

hcs_horiz_speed_max		EQU 9
hcs_horiz_speed_angle_speed	EQU 1

hcs_horiz_step_min		EQU 1
hcs_horiz_step_max		EQU 4
hcs_horiz_step_angle_speed	EQU 1

hcs_objects_per_sprite_number	EQU hcs_reused_sprites_number/(hcs_used_sprites_number/2)
hcs_objects_number		EQU hcs_objects_per_sprite_number*(hcs_used_sprites_number/2)

; Single-Corkscrew-Scroll 
scs_image_x_size		EQU 320
scs_image_plane_width		EQU scs_image_x_size/8
scs_image_depth			EQU 2
scs_origin_char_x_size		EQU 32
scs_origin_char_y_size		EQU 32

scs_text_char_x_size		EQU 32
scs_text_char_width		EQU scs_text_char_x_size/8
scs_text_char_y_size		EQU scs_origin_char_y_size
scs_text_char_depth		EQU scs_image_depth

scs_horiz_scroll_window_x_size	EQU vp2_visible_pixels_number+(scs_text_char_x_size*2)
scs_horiz_scroll_window_width	EQU scs_horiz_scroll_window_x_size/8
scs_horiz_scroll_window_y_size	EQU vp2_visible_lines_number*2
scs_horiz_scroll_window_depth	EQU scs_image_depth
scs_horiz_scroll_speed		EQU 2

scs_vert_scroll_window_x_size	EQU vp2_visible_pixels_number
scs_vert_scroll_window_width	EQU scs_vert_scroll_window_x_size/8
scs_vert_scroll_window_y_size	EQU vp2_visible_lines_number*2
scs_vert_scroll_window_depth	EQU scs_image_depth
scs_vert_scroll_speed1		EQU 2	; corkscrew effect on
scs_vert_scroll_speed2		EQU 1	; corkscrew effect off

scs_text_char_x_shift_max	EQU scs_text_char_x_size
scs_text_char_x_restart		EQU vp2_visible_pixels_number+64
scs_text_char_y_restart		EQU 48
scs_text_char_vert_speed	EQU 1
scs_text_characters_number	EQU scs_horiz_scroll_window_x_size/scs_text_char_x_size

scs_text_x_position		EQU 48
scs_text_y_position		EQU 0

scs_text_delay			EQU (1*(scs_vert_scroll_window_y_size))+1 ; no FPS delay so that the text moves smoothly after the delay

scs_center_bar_height		EQU 10

; Scrolltext stauchen 
scs_roller_y_radius		EQU vp2_visible_lines_number/2
scs_roller_y_center		EQU vp2_visible_lines_number/2
scs_roller_y_angle_step		EQU (sine_table_length1/2)/vp2_visible_lines_number

; Pipe-Effekt 
scs_pipe_shift_x_radius		EQU scs_roller_y_radius
scs_pipe_shift_x_center		EQU scs_roller_y_radius

; Sine-Bars 
sb_bar_height			EQU 10
sb_y_radius			EQU ((vp2_visible_lines_number-sb_bar_height)/2)-1

; Sine-Bars 2.3.2 
sb232_bars_number		EQU 8
sb232_y_center			EQU (vp2_visible_lines_number-sb_bar_height)/2
sb232_y_radius_angle_speed	EQU 1
sb232_y_radius_angle_step	EQU 3
sb232_y_angle_speed		EQU 2
sb232_y_distance		EQU 14

; Sine-Bars 3.6 
sb36_bars_number		EQU 4
sb36_y_center			EQU (vp2_visible_lines_number-sb_bar_height)/2
sb36_y_angle_speed		EQU 2
sb36_y_distance_min		EQU 32
sb36_y_distance_max		EQU sine_table_length1/sb36_bars_number
sb36_y_distance_radius		EQU ((sb36_y_distance_max-sb36_y_distance_min)/2)
sb36_y_distance_center		EQU ((sb36_y_distance_max-sb36_y_distance_min)/2)+sb36_y_distance_min
sb36_y_distance_speed		EQU 1
sb36_y_distance_step1		EQU 1

; Move-Ship 
ms_image_x_size			EQU 64
ms_image_plane_width		EQU ms_image_x_size/8
ms_image_y_size			EQU 32
ms_image_depth			EQU 4

ms_x_radius			EQU 384+64
ms_x_center			EQU 384+64

; Move-Ship-Left 
msl_x_angle_speed		EQU 1
msl_spaceship_y_position	EQU vp2_VSTART+((vp2_visible_lines_number-ms_image_y_size)/2)

; Move-Ship-Right 
msr_x_angle_speed		EQU 1
msr_spaceship_y_position	EQU vp2_VSTART+((vp2_visible_lines_number-ms_image_y_size)/2)

; Radius-Fader 
rf_max_y_radius			EQU sb_y_radius*2

; Radius-Fader-In 
rfi_delay			EQU 4
rfi_delay_speed			EQU 1
rfi_speed			EQU 1

; Radius-Fader-Out 
rfo_delay			EQU 3
rfo_delay_speed			EQU 1
rfo_speed			EQU 1

; Image-Fader 
if_rgb8_start_color		EQU 1
if_rgb8_color_table_offset	EQU 1
if_rgb8_colors_number		EQU vp1_pf1_colors_number-1

; Image-Fader-In 
ifi_rgb8_fader_speed_max	EQU 4
ifi_rgb8_fader_radius		EQU ifi_rgb8_fader_speed_max
ifi_rgb8_fader_center		EQU ifi_rgb8_fader_speed_max+1
ifi_rgb8_fader_angle_speed	EQU 2

; Image-Fader-Out 
ifo_rgb8_fader_speed_max	EQU 3
ifo_rgb8_fader_radius		EQU ifo_rgb8_fader_speed_max
ifo_rgb8_fader_center		EQU ifo_rgb8_fader_speed_max+1
ifo_rgb8_fader_angle_speed	EQU 1

; Sprite-Fader 
sprf_rgb8_start_color		EQU 1
sprf_rgb8_color_table_offset	EQU 1
sprf_rgb8_colors_number		EQU spr_colors_number-1

; Sprite-Fader-In 
sprfi_rgb8_fader_speed_max	EQU 2
sprfi_rgb8_fader_radius		EQU sprfi_rgb8_fader_speed_max
sprfi_rgb8_fader_center		EQU sprfi_rgb8_fader_speed_max+1
sprfi_rgb8_fader_angle_speed	EQU 1

; Sprite-Fader-Out 
sprfo_rgb8_fader_speed_max	EQU 2
sprfo_rgb8_fader_radius		EQU sprfo_rgb8_fader_speed_max
sprfo_rgb8_fader_center		EQU sprfo_rgb8_fader_speed_max+1
sprfo_rgb8_fader_angle_speed	EQU 1

; Bar-Fader 
bf_rgb8_color_table_offset	EQU 0
bf_rgb8_colors_number		EQU sb_bar_height

; Bar-Fader-In 
bfi_rgb8_fader_speed_max	EQU 4
bfi_rgb8_fader_radius		EQU bfi_rgb8_fader_speed_max
bfi_rgb8_fader_center		EQU bfi_rgb8_fader_speed_max+1
bfi_rgb8_fader_angle_speed	EQU 2

; Bar-Fader-Out 
bfo_rgb8_fader_speed_max	EQU 3
bfo_rgb8_fader_radius		EQU bfo_rgb8_fader_speed_max
bfo_rgb8_fader_center		EQU bfo_rgb8_fader_speed_max+1
bfo_rgb8_fader_angle_speed	EQU 1


extra_pf2_1_plane_x_offset	EQU 1*vp2_pf_pixel_per_datafetch
extra_pf2_1_plane_y_offset	EQU vp2_visible_lines_number
extra_pf2_2_plane_x_offset	EQU 1*vp2_pf_pixel_per_datafetch
extra_pf2_2_plane_y_offset	EQU vp2_visible_lines_number-1


	INCLUDE "except-vectors.i"


	INCLUDE "extra-pf-attributes.i"


	INCLUDE "sprite-attributes.i"


; PT-Replay 
	INCLUDE "music-tracker/pt-song.i"

	INCLUDE "music-tracker/pt-temp-channel.i"


	RSRESET

cl1_begin			RS.B 0

	INCLUDE "copperlist1.i"

cl1_COPJMP2			RS.L 1

copperlist1_size		RS.B 0


	RSRESET

cl2_extension1			RS.B 0

cl2_ext1_WAIT			RS.L 1
cl2_ext1_BPL1DAT		RS.L 1

cl2_extension1_size		RS.B 0


	RSRESET

cl2_extension2			RS.B 0

cl2_ext2_DDFSTRT		RS.L 1
cl2_ext2_DDFSTOP		RS.L 1
cl2_ext2_BPLCON1		RS.L 1
cl2_ext2_BPLCON2		RS.L 1
cl2_ext2_BPLCON3_1		RS.L 1
cl2_ext2_BPL1MOD		RS.L 1
cl2_ext2_BPL2MOD		RS.L 1
cl2_ext2_BPLCON4		RS.L 1
cl2_ext2_FMODE			RS.L 1
cl2_ext2_COLOR00_high1		RS.L 1
cl2_ext2_COLOR01_high1		RS.L 1
cl2_ext2_COLOR02_high1		RS.L 1
cl2_ext2_COLOR03_high1		RS.L 1
cl2_ext2_COLOR04_high1		RS.L 1
cl2_ext2_COLOR05_high1		RS.L 1
cl2_ext2_COLOR06_high1		RS.L 1
cl2_ext2_COLOR07_high1		RS.L 1
cl2_ext2_COLOR08_high1		RS.L 1
cl2_ext2_COLOR09_high1		RS.L 1
cl2_ext2_COLOR10_high1		RS.L 1
cl2_ext2_COLOR11_high1		RS.L 1
cl2_ext2_COLOR12_high1		RS.L 1
cl2_ext2_COLOR13_high1		RS.L 1
cl2_ext2_COLOR14_high1		RS.L 1
cl2_ext2_COLOR15_high1		RS.L 1
cl2_ext2_BPLCON3_low1		RS.L 1
cl2_ext2_COLOR00_low1		RS.L 1
cl2_ext2_COLOR01_low1		RS.L 1
cl2_ext2_COLOR02_low1		RS.L 1
cl2_ext2_COLOR03_low1		RS.L 1
cl2_ext2_COLOR04_low1		RS.L 1
cl2_ext2_COLOR05_low1		RS.L 1
cl2_ext2_COLOR06_low1		RS.L 1
cl2_ext2_COLOR07_low1		RS.L 1
cl2_ext2_COLOR08_low1		RS.L 1
cl2_ext2_COLOR09_low1		RS.L 1
cl2_ext2_COLOR10_low1		RS.L 1
cl2_ext2_COLOR11_low1		RS.L 1
cl2_ext2_COLOR12_low1		RS.L 1
cl2_ext2_COLOR13_low1		RS.L 1
cl2_ext2_COLOR14_low1		RS.L 1
cl2_ext2_COLOR15_low1		RS.L 1
cl2_ext2_BPL1PTH		RS.L 1
cl2_ext2_BPL1PTL		RS.L 1
cl2_ext2_BPL2PTH		RS.L 1
cl2_ext2_BPL2PTL		RS.L 1
cl2_ext2_BPL3PTH		RS.L 1
cl2_ext2_BPL3PTL		RS.L 1
cl2_ext2_BPL4PTH		RS.L 1
cl2_ext2_BPL4PTL		RS.L 1

cl2_extension2_size		RS.B 0


	RSRESET

cl2_extension3			RS.B 0

cl2_ext3_WAIT			RS.L 1
cl2_ext3_BPLCON1_1		RS.L 1
cl2_ext3_BPLCON1_2		RS.L 1
cl2_ext3_BPLCON1_3		RS.L 1
cl2_ext3_BPLCON1_4		RS.L 1
cl2_ext3_BPLCON1_5		RS.L 1
cl2_ext3_BPLCON1_6		RS.L 1
cl2_ext3_BPLCON1_7		RS.L 1
cl2_ext3_BPLCON1_8		RS.L 1
cl2_ext3_BPLCON1_9		RS.L 1
cl2_ext3_BPLCON1_10		RS.L 1
cl2_ext3_BPLCON1_11		RS.L 1
cl2_ext3_BPLCON1_12		RS.L 1
cl2_ext3_BPLCON1_13		RS.L 1
cl2_ext3_BPLCON1_14		RS.L 1
cl2_ext3_BPLCON1_15		RS.L 1
cl2_ext3_BPLCON1_16		RS.L 1
cl2_ext3_BPLCON1_17		RS.L 1
cl2_ext3_BPLCON1_18		RS.L 1
cl2_ext3_BPLCON1_19		RS.L 1
cl2_ext3_BPLCON1_20		RS.L 1
cl2_ext3_BPLCON1_21		RS.L 1
cl2_ext3_BPLCON1_22		RS.L 1
cl2_ext3_BPLCON1_23		RS.L 1
cl2_ext3_BPLCON1_24		RS.L 1
cl2_ext3_BPLCON1_25		RS.L 1
cl2_ext3_BPLCON1_26		RS.L 1
cl2_ext3_BPLCON1_27		RS.L 1
cl2_ext3_BPLCON1_28		RS.L 1
cl2_ext3_BPLCON1_29		RS.L 1
cl2_ext3_BPLCON1_30		RS.L 1
cl2_ext3_BPLCON1_31		RS.L 1
cl2_ext3_BPLCON1_32		RS.L 1
cl2_ext3_BPLCON1_33		RS.L 1
cl2_ext3_BPLCON1_34		RS.L 1
cl2_ext3_BPLCON1_35		RS.L 1
cl2_ext3_BPLCON1_36		RS.L 1
cl2_ext3_BPLCON1_37		RS.L 1
cl2_ext3_BPLCON1_38		RS.L 1
cl2_ext3_BPLCON1_39		RS.L 1
cl2_ext3_BPLCON1_40		RS.L 1

cl2_extension3_size		RS.B 0


	RSRESET

cl2_extension4			RS.B 0

cl2_ext4_WAIT			RS.L 1
cl2_ext4_BPL1DAT		RS.L 1

cl2_extension4_size		RS.B 0


	RSRESET

cl2_extension5			RS.B 0

cl2_ext5_DDFSTRT		RS.L 1
cl2_ext5_DDFSTOP		RS.L 1
cl2_ext5_BPLCON1		RS.L 1
cl2_ext5_BPLCON2		RS.L 1
cl2_ext5_BPLCON3_1		RS.L 1
cl2_ext5_BPL1MOD		RS.L 1
cl2_ext5_BPL2MOD		RS.L 1
cl2_ext5_BPLCON4		RS.L 1
cl2_ext5_FMODE			RS.L 1
cl2_ext5_COLOR00_high1		RS.L 1
cl2_ext5_COLOR04_high1		RS.L 1
cl2_ext5_BPLCON3_low1		RS.L 1
cl2_ext5_COLOR00_low1		RS.L 1
cl2_ext5_COLOR04_low1		RS.L 1
cl2_ext5_BPL1PTH		RS.L 1
cl2_ext5_BPL1PTL		RS.L 1
cl2_ext5_BPL2PTH		RS.L 1
cl2_ext5_BPL2PTL		RS.L 1
cl2_ext5_BPL3PTH		RS.L 1
cl2_ext5_BPL3PTL		RS.L 1
cl2_ext5_BPL4PTH		RS.L 1
cl2_ext5_BPL4PTL		RS.L 1

cl2_extension5_size		RS.B 0


	RSRESET

cl2_extension6			RS.B 0

cl2_ext6_WAIT			RS.L 1
	IFEQ scs_pipe_effect
cl2_ext6_BPLCON1		RS.L 1
	ENDC
cl2_ext6_BPLCON3_1		RS.L 1
cl2_ext6_BPL1MOD		RS.L 1
cl2_ext6_BPL2MOD		RS.L 1
	IFEQ scs_center_bar
cl2_ext6_COLOR00_high		RS.L 1
	ENDC
cl2_ext6_COLOR01_high		RS.L 1
cl2_ext6_COLOR02_high		RS.L 1
cl2_ext6_COLOR05_high		RS.L 1
cl2_ext6_COLOR06_high		RS.L 1
cl2_ext6_BPLCON3_2		RS.L 1
	IFEQ scs_center_bar
cl2_ext6_COLOR00_low		RS.L 1
	ENDC
cl2_ext6_COLOR01_low		RS.L 1
cl2_ext6_COLOR02_low		RS.L 1
cl2_ext6_COLOR05_low		RS.L 1
cl2_ext6_COLOR06_low		RS.L 1
cl2_ext6_NOOP			RS.L 1

cl2_extension6_size		RS.B 0


	RSRESET

cl2_begin			RS.B 0

; Vertical-Blank 1
cl2_extension1_entry		RS.B cl2_extension1_size*vb1_lines_number

; Viewport 1
cl2_extension2_entry		RS.B cl2_extension2_size
cl2_WAIT1			RS.L 1
cl2_bplcon0_1			RS.L 1
cl2_extension3_entry		RS.B cl2_extension3_size*hsi_lines_number
cl2_WAIT2			RS.L 1
cl2_bplcon0_2			RS.L 1

; Vertical-Blank 2
cl2_extension4_entry		RS.B cl2_extension4_size*vb2_lines_number

; Viewport 2
cl2_extension5_entry		RS.B cl2_extension5_size
cl2_WAIT3			RS.L 1
cl2_bplcon0_3			RS.L 1
cl2_extension6_entry		RS.B cl2_extension6_size*vp2_visible_lines_number

; Copper-Interrupt
cl2_WAIT5			RS.L 1
cl2_INTREQ			RS.L 1

cl2_end				RS.L 1

copperlist2_size		RS.B 0


cl1_size1			EQU 0
cl1_size2			EQU 0
cl1_size3			EQU copperlist1_size

cl2_size1			EQU 0
cl2_size2			EQU copperlist2_size
cl2_size3			EQU copperlist2_size


; Sprite0 additional structure 
	RSRESET

spr0_extension1			RS.B 0

spr0_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr0_ext1_planedata		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)*hcs_image_y_size

spr0_extension1_size		RS.B 0

	RSRESET

spr0_extension2	RS.B 0

spr0_ext2_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr0_ext2_planedata		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)*ms_image_y_size

spr0_extension2_size		RS.B 0

; Sprite0 main structure 
	RSRESET

spr0_begin			RS.B 0

spr0_extension1_entry		RS.B spr0_extension1_size*hcs_objects_per_sprite_number
spr0_extension2_entry		RS.L spr0_extension2_size

spr0_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite0_size			RS.B 0

; Sprite1 additional structure 
	RSRESET

spr1_extension1	RS.B 0

spr1_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr1_ext1_planedata		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)*hcs_image_y_size

spr1_extension1_size		RS.B 0

	RSRESET

spr1_extension2	RS.B 0

spr1_ext2_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr1_ext2_planedata		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)*ms_image_y_size

spr1_extension2_size		RS.B 0

; Sprite1 main structure 
	RSRESET

spr1_begin			RS.B 0

spr1_extension1_entry		RS.B spr1_extension1_size*hcs_objects_per_sprite_number
spr1_extension2_entry		RS.B spr1_extension2_size

spr1_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite1_size			RS.B 0

; Sprite2 additional structure 
	RSRESET

spr2_extension1	RS.B 0

spr2_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr2_ext1_planedata		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)*hcs_image_y_size

spr2_extension1_size		RS.B 0

; Sprite2 main structure 
	RSRESET

spr2_begin			RS.B 0

spr2_extension1_entry		RS.B spr2_extension1_size*hcs_objects_per_sprite_number

spr2_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite2_size			RS.B 0

; Sprite3 additional structure 
	RSRESET

spr3_extension1	RS.B 0

spr3_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr3_ext1_planedata		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)*hcs_image_y_size

spr3_extension1_size		RS.B 0

; Sprite3 main structure 
	RSRESET

spr3_begin			RS.B 0

spr3_extension1_entry		RS.B spr3_extension1_size*hcs_objects_per_sprite_number

spr3_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite3_size			RS.B 0

; Sprite4 additional structure 
	RSRESET

spr4_extension1			RS.B 0

spr4_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr4_ext1_planedata		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)*hcs_image_y_size

spr4_extension1_size		RS.B 0

; Sprite4 main structure 
	RSRESET

spr4_begin			RS.B 0

spr4_extension1_entry		RS.B spr4_extension1_size*hcs_objects_per_sprite_number

spr4_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite4_size			RS.B 0

; Sprite5 additional structure 
	RSRESET

spr5_extension1		RS.B 0

spr5_ext1_header		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)
spr5_ext1_planedata		RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)*hcs_image_y_size

spr5_extension1_size		RS.B 0

; Sprite5 main structure 
	RSRESET

spr5_begin			RS.B 0

spr5_extension1_entry		RS.B spr5_extension1_size*hcs_objects_per_sprite_number

spr5_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite5_size			RS.B 0

; Sprite6 main structure 
	RSRESET

spr6_begin			RS.B 0

spr6_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite6_size			RS.B 0

; Sprite7 main structure 
	RSRESET

spr7_begin			RS.B 0

spr7_end			RS.L 1*(spr_pixel_per_datafetch/WORD_BITS)

sprite7_size			RS.B 0


spr0_x_size1			EQU spr_x_size1
spr0_y_size1			EQU sprite0_size/(spr_x_size1/8)
spr1_x_size1			EQU spr_x_size1
spr1_y_size1			EQU sprite1_size/(spr_x_size1/8)
spr2_x_size1			EQU spr_x_size1
spr2_y_size1			EQU sprite2_size/(spr_x_size1/8)
spr3_x_size1			EQU spr_x_size1
spr3_y_size1			EQU sprite3_size/(spr_x_size1/8)
spr4_x_size1			EQU spr_x_size1
spr4_y_size1			EQU sprite4_size/(spr_x_size1/8)
spr5_x_size1			EQU spr_x_size1
spr5_y_size1			EQU sprite5_size/(spr_x_size1/8)
spr6_x_size1			EQU spr_x_size1
spr6_y_size1			EQU sprite6_size/(spr_x_size1/8)
spr7_x_size1			EQU spr_x_size1
spr7_y_size1			EQU sprite7_size/(spr_x_size1/8)

spr0_x_size2			EQU spr_x_size2
spr0_y_size2			EQU sprite0_size/(spr_x_size2/8)
spr1_x_size2			EQU spr_x_size2
spr1_y_size2			EQU sprite1_size/(spr_x_size2/8)
spr2_x_size2			EQU spr_x_size2
spr2_y_size2			EQU sprite2_size/(spr_x_size2/8)
spr3_x_size2			EQU spr_x_size2
spr3_y_size2			EQU sprite3_size/(spr_x_size2/8)
spr4_x_size2			EQU spr_x_size2
spr4_y_size2			EQU sprite4_size/(spr_x_size2/8)
spr5_x_size2			EQU spr_x_size2
spr5_y_size2			EQU sprite5_size/(spr_x_size2/8)
spr6_x_size2			EQU spr_x_size2
spr6_y_size2			EQU sprite6_size/(spr_x_size2/8)
spr7_x_size2			EQU spr_x_size2
spr7_y_size2			EQU sprite7_size/(spr_x_size2/8)


	RSRESET

	INCLUDE "main-variables.i"

; PT-Replay 
	IFD PROTRACKER_VERSION_2 
		INCLUDE "music-tracker/pt2-variables.i"
	ENDC
	IFD PROTRACKER_VERSION_3
		INCLUDE "music-tracker/pt3-variables.i"
	ENDC

pt_effects_handler_active	RS.W 1

; Horiz-Scaling-Image 
hsi_x_radius_angle		RS.W 1
hsi_x_radius_angle_step	RS.W 1

; Horiz-Character-Scrolling 
hcs_get_horiz_speed_active	RS.W 1
hcs_horiz_speed_angle		RS.W 1
hcs_horiz_speed			RS.W 1

hcs_get_horiz_step_active	RS.W 1
hcs_horiz_step_angle		RS.W 1
hcs_horiz_step			RS.W 1

; Single-Corkscrew-Scroll 
	RS_ALIGN_LONGWORD
scs_image			RS.L 1
scs_enabled			RS.W 1
scs_text_table_start		RS.W 1
scs_text_char_x_shift		RS.W 1
scs_text_char_y_offset		RS.W 1
scs_variable_vert_scroll_speed	RS.W 1
scs_text_delay_counter		RS.W 1
scs_text_move_active		RS.W 1

; Sine-Bars 
sb_variable_y_radius		RS.W 1

; Sine-Bars 2.3.2 
sb232_active			RS.W 1
sb232_y_radius_angle		RS.W 1
sb232_y_angle			RS.W 1

; Sine-Bars 3.6 
sb36_active			RS.W 1
sb36_y_angle			RS.W 1
sb36_y_distance_angle		RS.W 1

; Move-Spaceship-Left 
msl_active			RS.W 1
msl_x_angle			RS.W 1

; Move-Spaceship-Right 
msr_active			RS.W 1
msr_x_angle			RS.W 1

; Radius-Fader-In 
rfi_active			RS.W 1
rfi_delay_counter		RS.W 1

; Radius-Fader-Out 
rfo_active			RS.W 1
rfo_delay_counter		RS.W 1

; Image-Fader 
if_rgb8_colors_counter		RS.W 1
if_rgb8_copy_colors_active	RS.W 1

; Image-Fader-In 
ifi_rgb8_active			RS.W 1
ifi_rgb8_fader_angle		RS.W 1

; Image-Fader-Out 
ifo_rgb8_active			RS.W 1
ifo_rgb8_fader_angle		RS.W 1

; Sprite-Fader 
sprf_rgb8_colors_counter	RS.W 1
sprf_rgb8_copy_colors_active	RS.W 1

; Sprite-Fader-In 
sprfi_rgb8_active		RS.W 1
sprfi_rgb8_fader_angle		RS.W 1

; Sprite-Fader-Out 
sprfo_rgb8_active		RS.W 1
sprfo_rgb8_fader_angle		RS.W 1

; Bar-Fader 
bf_rgb8_colors_counter		RS.W 1
bf_rgb8_convert_colors_active	RS.W 1

; Bar-Fader-In 
bfi_rgb8_active			RS.W 1
bfi_rgb8_fader_angle		RS.W 1

; Bar-Fader-Out 
bfo_rgb8_active			RS.W 1
bfo_rgb8_fader_angle		RS.W 1

; Main 
mh_start_spaceship_active	RS.W 1
stop_fx_active			RS.W 1
exit_active			RS.W 1

variables_size			RS.B 0


	SECTION code,CODE


	INCLUDE "sys-wrapper.i"


	CNOP 0,4
init_main_variables

; PT-Replay 
	IFD PROTRACKER_VERSION_2 
		PT2_INIT_VARIABLES
	ENDC
	IFD PROTRACKER_VERSION_3
		PT3_INIT_VARIABLES
	ENDC

	moveq	#TRUE,d0
	move.w	d0,pt_effects_handler_active(a3)

; Horiz-Scaling-Image 
	move.w	d0,hsi_x_radius_angle(a3) ; 0°
	move.w	d0,hsi_x_radius_angle_step(a3) ; 0°

; Horiz-Character-Scrolling 
	move.w	d0,hcs_get_horiz_speed_active(a3)
	MOVEF.W sine_table_length1/4,d2
	move.w	d2,hcs_horiz_speed_angle(a3) : 90°
	move.w	d0,hcs_horiz_speed(a3)
	moveq	#FALSE,d1
	move.w	d1,hcs_get_horiz_step_active(a3)
	move.w	d2,hcs_horiz_step_angle(a3) ; 90°
	moveq	#hcs_horiz_step_min,d2
	move.w	d2,hcs_horiz_step(a3)

; Single-Corkscrew-Scroll 
	lea	scs_image_data,a0
	move.w	d1,scs_enabled(a3)
	move.l	a0,scs_image(a3)
	move.w	d0,scs_text_table_start(a3)
	move.w	d0,scs_text_char_x_shift(a3)
	move.w	#scs_text_char_y_restart*extra_pf2_plane_width*scs_vert_scroll_window_depth,scs_text_char_y_offset(a3)
	move.w	#scs_vert_scroll_speed2,scs_variable_vert_scroll_speed(a3)
	move.w	d1,scs_text_delay_counter(a3) ; counter inactive
	move.w	d0,scs_text_move_active(a3)

; Sine-Bars 
	move.w	d0,hcs_horiz_step_angle(a3) ; 0°
	move.w	d0,sb_variable_y_radius(a3) : 0°

; Sine-Bars 2.3.2 
	move.w	d1,sb232_active(a3)
	move.w	d0,sb232_y_radius_angle(a3) ; 0°
	move.w	d0,sb232_y_angle(a3) ;0°

; Sine-Bars 3.6 
	move.w	d1,sb36_active(a3)
	move.w	d0,sb36_y_angle(a3) ;0°
	move.w	d0,sb36_y_distance_angle(a3) ; 0°

; Move-Spaceship 
	move.w	d1,msl_active(a3)
	MOVEF.W sine_table_length2/4,d3
	move.w	d3,msl_x_angle(a3) ;90°

	move.w	d1,msr_active(a3)
	move.w	d3,msr_x_angle(a3) ;90°

; Radius-Fader-In 
	move.w	d1,rfi_active(a3)
	move.w	d0,rfi_delay_counter(a3)

; Radius-Fader-Out *
	move.w	d1,rfo_active(a3)
	move.w	d0,rfo_delay_counter(a3)

; Image-Fader 
	move.w	d0,if_rgb8_colors_counter(a3)
	move.w	d1,if_rgb8_copy_colors_active(a3)

; Image-Fader-In 
	move.w	d1,ifi_rgb8_active(a3)
	move.w	d2,ifi_rgb8_fader_angle(a3) ; 90°

; Image-Fader-Out 
	move.w	d1,ifo_rgb8_active(a3)
	move.w	d2,ifo_rgb8_fader_angle(a3) ; 90°

; Sprite-Fader 
	move.w	d0,sprf_rgb8_colors_counter(a3)
	move.w	d1,sprf_rgb8_copy_colors_active(a3)

; Sprite-Fader-In 
	move.w	d1,sprfi_rgb8_active(a3)
	MOVEF.W sine_table_length1/4,d2
	move.w	d2,sprfi_rgb8_fader_angle(a3) ; 90°

; Sprite-Fader-Out 
	move.w	d1,sprfo_rgb8_active(a3)
	move.w	d2,sprfo_rgb8_fader_angle(a3) ; 90°

; Bar-Fader 
	move.w	d0,bf_rgb8_colors_counter(a3)
	move.w	d1,bf_rgb8_convert_colors_active(a3)

; Bar-Fader-In 
	move.w	d1,bfi_rgb8_active(a3)
	MOVEF.W sine_table_length1/4,d2
	move.w	d2,bfi_rgb8_fader_angle(a3) ; 90°

; Bar-Fader-Out 
	move.w	d1,bfo_rgb8_active(a3)
	move.w	d2,bfo_rgb8_fader_angle(a3) ; 90°

; Main 
	move.w	d1,mh_start_spaceship_active(a3)
	move.w	d1,stop_fx_active(a3)
	move.w	d1,exit_active(a3)
	rts


	CNOP 0,4
init_main
	bsr	pt_DetectSysFrEQU
	bsr	pt_InitRegisters
	bsr	pt_InitAudTempStrucs
	bsr	pt_ExamineSongStruc
	bsr	pt_InitFtuPeriodTableStarts
	bsr	bg_copy_image_to_plane
	bsr	hsi_init_shift_table
	bsr	scs_init_characters_offsets
	IFEQ scs_pipe_effect
		bsr	scs_init_x_shift_table
	ENDC
	bsr	bf_rgb8_init_color_table
	bsr	init_colors
	bsr	init_sprites
	bsr	init_CIA_timers
	bsr	init_first_copperlist
	bra	init_second_copperlist


; PT-Replay 
	PT_DETECT_SYS_FREQUENCY

	PT_INIT_REGISTERS

	PT_INIT_AUDIO_TEMP_STRUCTURES

	PT_EXAMINE_SONG_STRUCTURE

	PT_INIT_FINETUNE_TABLE_STARTS


; Background-Image 
	COPY_IMAGE_TO_BITPLANE bg,bg_image_x_position,bg_image_y_position,extra_pf1


; Horiz-Scaling-Image 
	CNOP 0,4
hsi_init_shift_table
	moveq	#0,d0			; 1st horiz shift
	lea	hsi_shift_table(pc),a0
	moveq	#hsi_shift_values_number-1,d7
hsi_init_shift_table_loop
	move.b	d0,(a0)+
	addq.w	#1*SHIRES_PIXEL_FACTOR,d0
	dbf	d7,hsi_init_shift_table_loop
	rts


; Single-Corkscrew-Scroll 
	INIT_CHARACTERS_OFFSETS.W scs

	IFEQ scs_pipe_effect
		CNOP 0,4
scs_init_x_shift_table
		moveq	#0,d1		; 1st y angle
		moveq	#scs_pipe_shift_x_radius*2,d2
		MOVEF.L sine_table_length1/2,d3 ; 180°
		divu.w	#scs_roller_y_radius*2,d3 ; steps in sine table
		lea	sine_table(pc),a0
		lea	scs_pipe_shift_x_table(pc),a1
		moveq	#(scs_roller_y_radius*2)-1,d7 ; number of lines
scs_init_x_shift_table_loop
		move.w	2(a0,d1.w*4),d0	; sin(w)
		muls.w	d2,d0		; x'=(xr*sin(w))/2^15
		swap	d0
		move.w	d0,(a1)+
		add.w	d3,d1		; next x angle
		dbf	d7,scs_init_x_shift_table_loop
		rts
	ENDC


; Bar-Fader 
	CNOP 0,4
bf_rgb8_init_color_table
	clr.w	bf_rgb8_convert_colors_active(a3)
	bra	bf_rgb8_convert_colors


	CNOP 0,4
init_colors
	CPU_SELECT_COLOR_HIGH_BANK 1
	CPU_INIT_COLOR_HIGH COLOR00,16,vp2_spr_rgb8_color_table

	CPU_SELECT_COLOR_LOW_BANK 1
	CPU_INIT_COLOR_LOW COLOR00,16,vp2_spr_rgb8_color_table
	rts


	CNOP 0,4
init_sprites
	bsr.s	spr_init_ptrs_table
	bsr.s	hcs_init_xy_coords
	bsr	hcs_init_sprites_bitmaps
	bra	spr_copy_structures


	INIT_SPRITE_POINTERS_TABLE


; Horiz-Characterscrolling 
	CNOP 0,4
hcs_init_xy_coords
	movem.l a4-a5,-(a7)
	moveq	#0,d3
	not.w	d3			; mask = $0000ffff
	move.w	#hcs_random_x_max,d4
	lea	spr_ptrs_construction(pc),a2
	lea	hcs_objects_x_coords(pc),a5
	moveq	#hcs_z_planes_number-1,d7	; number of used sprites
hcs_init_xy_coords_loop1
	move.w	VHPOSR-DMACONR(a6),d5	; f(x)
	move.l	(a2)+,a0		; 1st sprite structure
	move.l	(a2)+,a1		; 2nd sprite structure
	move.w	#display_window_vstart,a4 ; 1st y
	moveq	#hcs_objects_per_sprite_number-1,d6
hcs_init_xy_coords_loop2
	mulu.w	VHPOSR-DMACONR(a6),d5	; f(x)*a
	move.w	VHPOSR-DMACONR(a6),d1
	swap	d1
	move.b	_CIAA+CIATODLOW,d1
	lsl.w	#8,d1
	move.b	_CIAB+CIATODLOW,d1	; b
	add.l	d1,d5			; (f(x)*a)+b
	and.l	d3,d5			; only low word
	divu.w	d4,d5			; f(x+1)=[(f(x)*a)+b]/mod
	swap	d5			; remainder
	move.w	d5,d0
	IFNE hcs_quick_x_max_restart
		add.w	#hcs_x_min,d0
	ENDC
	move.w	d0,(a5)+		; x coordinate
	move.w	a4,d1			; y
	bsr.s	hcs_init_sprite_header
	ADDF.W	spr2_extension1_size,a0	; skip n bytes
	ADDF.W	spr3_extension1_size,a1
	ADDF.W	hcs_image_y_size+1,a4	; increase y
	dbf	d6,hcs_init_xy_coords_loop2
	dbf	d7,hcs_init_xy_coords_loop1
	movem.l (a7)+,a4-a5
	rts

; Input
; d0.w	X
; d1.w	Y
; a0.l	Pointer 1st sprite structure
; a1.l	Pointer 2nd sprite structure
; Result
	CNOP 0,4
hcs_init_sprite_header
	moveq	#hcs_image_y_size,d2	; height
	add.w	d1,d2			; VSTOP
	SET_SPRITE_POSITION d0,d1,d2
	move.w	d1,(a0)			; SPRxPOS
	move.w	d2,spr_pixel_per_datafetch/8(a0) ; SPRxCTL
	move.w	d1,(a1)			; SPRxPOS
	or.b	#SPRCTLF_ATT,d2
	move.w	d2,spr_pixel_per_datafetch/8(a1) ; SPRxCTL
	rts

	CNOP 0,4
hcs_init_sprites_bitmaps
	movem.l a3-a6,-(a7)
	moveq	#(spr_pixel_per_datafetch/8)*2,d2
	lea	spr_ptrs_construction(pc),a3
	lea	hcs_image_data,a4
	moveq	#hcs_z_planes_number-1,d7
hcs_init_sprites_bitmaps_loop1
	move.l	(a3)+,a0		; 1st sprite structure
	move.l	(a3)+,a1		; 2nd sprite structure
	moveq	#hcs_objects_per_sprite_number-1,d6
hcs_init_sprites_bitmaps_loop2
	ADDF.W	(spr_pixel_per_datafetch/8)*2,a0 ; skip header
	ADDF.W	(spr_pixel_per_datafetch/8)*2,a1
	move.l	a4,a2			; image data
	moveq	#hcs_image_y_size-1,d5
hcs_init_sprites_bitmaps_loop3
	move.w	(a2),(a0)		; bitplane 1 even sprite
	addq.w	#hcs_image_plane_width*hcs_z_planes_number,a2
	move.w	(a2),spr_pixel_per_datafetch/8(a0) ; bitplane 2 even sprite
	add.l	d2,a0			; next line in even sprite structure
	addq.w	#hcs_image_plane_width*hcs_z_planes_number,a2
	move.w	(a2),(a1)		; bitplane 3 odd sprite
	addq.w	#hcs_image_plane_width*hcs_z_planes_number,a2
	move.w	(a2),spr_pixel_per_datafetch/8(a1) ; bitplane 4 odd sprite
	add.l	d2,a1			; next line in odd sprite structure
	addq.w	#hcs_image_plane_width*hcs_z_planes_number,a2
	dbf	d5,hcs_init_sprites_bitmaps_loop3
	dbf	d6,hcs_init_sprites_bitmaps_loop2
	addq.w	#hcs_image_plane_width,a4 ; next character
	dbf	d7,hcs_init_sprites_bitmaps_loop1
	movem.l (a7)+,a3-a6
	rts

	COPY_SPRITE_STRUCTURES


	CNOP 0,4
init_CIA_timers

; PT-Replay 
	PT_INIT_TIMERS
	rts


	CNOP 0,4
init_first_copperlist
	move.l	cl1_display(a3),a0
	bsr.s	cl1_init_playfield_props
	bsr	cl1_init_sprite_ptrs
	bsr	cl1_init_colors
	COP_MOVEQ 0,COPJMP2
	bra	cl1_set_sprite_ptrs


	COP_INIT_PLAYFIELD_REGISTERS cl1,NOBITPLANESSPR


	COP_INIT_SPRITE_POINTERS cl1


	CNOP 0,4
cl1_init_colors
	COP_INIT_COLOR_HIGH COLOR16,16,spr_rgb8_color_table

	COP_SELECT_COLOR_LOW_BANK 0
	COP_INIT_COLOR_LOW COLOR16,16,spr_rgb8_color_table
	rts

	COP_SET_SPRITE_POINTERS cl1,display,spr_number


	CNOP 0,4
init_second_copperlist
	move.l	cl2_construction2(a3),a0

; Vertical-Blank 1
	bsr.s	cl2_vb1_init_bpldat

; Viewport 1
	bsr	cl2_vp1_init_playfield_props
	bsr	cl2_vp1_init_colors
	bsr	cl2_vp1_init_plane_ptrs
	COP_WAIT 0,vp1_VSTART
	COP_MOVEQ vp1_bplcon0_bits1,BPLCON0
	bsr	cl2_init_bplcon1s
	COP_WAIT 0,vp1_VSTOP
	COP_MOVEQ vp1_bplcon0_bits2,BPLCON0

; Vertical-Blank 2
	bsr	cl2_vb2_init_bpldat

; Viewport 2
	bsr	cl2_vp2_init_playfield_props
	bsr	cl2_vp2_init_colors
	bsr	cl2_vp2_init_plane_ptrs
	COP_WAIT 0,vp2_VSTART
	COP_MOVEQ vp2_bplcon0_bits1,BPLCON0
	bsr	cl2_init_roller

; Copper-Interrupt
	bsr	cl2_init_copper_interrupt
	COP_LISTEND
	bsr	cl2_vp1_set_plane_ptrs
	bsr	cl2_vp2_set_plane_ptrs
	bsr	scs_set_vert_compression
	IFEQ scs_pipe_effect
		bsr	scs_set_color_gradients
		bsr	scs_set_pipe
	ELSE
		bsr	scs_set_color_gradients
	ENDC
	bsr	copy_second_copperlist
	bra	swap_second_copperlist


; Vertical Blank 1
	CNOP 0,4
cl2_vb1_init_bpldat
	move.l	#(((cl2_vb1_VSTART<<24)|(((cl2_vb1_HSTART/4)*2)<<16))|$10000)|$fffe,d0 ; CWAIT
	move.l	#BPL1DAT<<16,d1
	moveq	#1,d2
	ror.l	#8,d2			; $01000000
	MOVEF.W vb1_lines_number-1,d7
cl2_vb1_init_bpldat_loop
	move.l	d0,(a0)+		; CWAIT x,y
	add.l	d2,d0			; next line in cl
	move.l	d1,(a0)+		; BPL1DAT
	dbf	d7,cl2_vb1_init_bpldat_loop
	rts


; Viewport 1
	COP_INIT_PLAYFIELD_REGISTERS cl2,,vp1

	CNOP 0,4
cl2_vp1_init_colors
	COP_INIT_COLOR_HIGH COLOR00,16,vp1_pf1_rgb8_color_table

	COP_SELECT_COLOR_LOW_BANK 0
	COP_INIT_COLOR_LOW COLOR00,16,vp1_pf1_rgb8_color_table
	rts

	CNOP 0,4
cl2_vp1_init_plane_ptrs
	MOVEF.W BPL1PTH,d0
	moveq	#(extra_pf1_depth*2)-1,d7
cl2_vp1_init_plane_ptrs_loop
	move.w	d0,(a0)			; BPLxPTH/L
	addq.w	#WORD_SIZE,d0
	addq.w	#LONGWORD_SIZE,a0
	dbf	d7,cl2_vp1_init_plane_ptrs_loop
	rts

	CNOP 0,4
cl2_vp1_set_plane_ptrs
	move.l	cl2_construction2(a3),a0 
	ADDF.W	cl2_extension2_entry+cl2_ext2_BPL1PTH+WORD_SIZE,a0
	move.l	extra_pf1(a3),a1
	moveq	#extra_pf1_depth-1,d7
cl2_vp1_set_plane_ptrs_loop
	move.w	(a1)+,(a0)		; BPLxPTH
	addq.w	#QUADWORD_SIZE,a0
	move.w	(a1)+,LONGWORD_SIZE-QUADWORD_SIZE(a0) ; BPLxPTL
	dbf	d7,cl2_vp1_set_plane_ptrs_loop
	rts

	COP_INIT_BPLCON1_CHUNKY_SCREEN cl2,cl2_vp1_HSTART,cl2_vp1_VSTART,cl2_display_x_size,vp1_visible_lines_number,vp1_bplcon1_bits


; Vertical-Blank 2
	CNOP 0,4
cl2_vb2_init_bpldat
	move.l	#(((cl2_vb2_VSTART<<24)|(((cl2_vb2_HSTART/4)*2)<<16))|$10000)|$fffe,d0 ; CWAIT
	move.l	#BPL1DAT<<16,d1
	moveq	#1,d2
	ror.l	#8,d2			; $01000000
	MOVEF.W vb2_lines_number-1,d7
cl2_vb2_init_bpldat_loop
	move.l	d0,(a0)+		; CWAIT x,y
	add.l	d2,d0			; next line in cl
	move.l	d1,(a0)+		; BPL1DAT
	dbf	d7,cl2_vb2_init_bpldat_loop
	rts


; Viewport 2
	COP_INIT_PLAYFIELD_REGISTERS cl2,,vp2

	CNOP 0,4
cl2_vp2_init_colors
	COP_INIT_COLOR_HIGH COLOR00,1,vp2_pf1_rgb8_color_table
	COP_INIT_COLOR_HIGH COLOR04,1,vp2_pf2_rgb8_color_table

	COP_SELECT_COLOR_LOW_BANK 0
	COP_INIT_COLOR_LOW COLOR00,1,vp2_pf1_rgb8_color_table
	COP_INIT_COLOR_LOW COLOR04,1,vp2_pf2_rgb8_color_table
	rts

	CNOP 0,4
cl2_vp2_init_plane_ptrs
	MOVEF.W BPL1PTH,d0
	moveq	#(extra_pf2_depth*2*2)-1,d7
cl2_vp2_init_plane_ptrs_loop
	move.w	d0,(a0)			; BPLxPTH/L
	addq.w	#WORD_SIZE,d0
	addq.w	#LONGWORD_SIZE,a0
	dbf	d7,cl2_vp2_init_plane_ptrs_loop
	rts

	CNOP 0,4
cl2_init_roller
	movem.l a4-a6,-(a7)
	move.l	#(((cl2_vp2_VSTART<<24)|(((cl2_vp2_HSTART/4)*2)<<16))|$10000)|$fffe,d0 ; CWAIT
	move.l	#(BPLCON3<<16)+vp2_bplcon3_bits1,d1 ; color low
	move.l	#COLOR01<<16,d2
	move.l	#(BPLCON3<<16)+vp2_bplcon3_bits2,d3 ; color low
	move.l	#COLOR02<<16,d4
	move.l	#COLOR05<<16,d5
	moveq	#1,d6
	ror.l	#8,d6			; $01000000
	move.l	#(BPL1MOD<<16)|((-extra_pf2_plane_width+(extra_pf2_plane_width-vp2_data_fetch_width))&$ffff),a1
	move.l	#(BPL2MOD<<16)|((-extra_pf2_plane_width+(extra_pf2_plane_width-vp2_data_fetch_width))&$ffff),a2
	IFEQ scs_pipe_effect
		move.l	#BPLCON1<<16,a4
	ENDC
	IFEQ scs_center_bar
		move.w	#COLOR00,a5
	ENDC
	move.l	#COLOR06<<16,a6
	moveq	#vp2_visible_lines_number-1,d7
cl2_init_roller_loop
	move.l	d0,(a0)+		; CWAIT x,y
	IFEQ scs_pipe_effect
		move.l	a4,(a0)+	; BPLCON1
	ENDC
	move.l	d1,(a0)+		; BPLCON3 color high
	move.l	a1,(a0)+		; BPL1MOD
	move.l	a2,(a0)+		; BPL2MOD
	IFEQ scs_center_bar
		move.w	a5,(a0)+	; COLOR00
		move.w	#color00_high_bits,(a0)+
	ENDC
	move.l	d2,(a0)+		; COLOR01
	move.l	d4,(a0)+		; COLOR02
	move.l	d5,(a0)+		; COLOR05
	move.l	a6,(a0)+		; COLOR06
	move.l	d3,(a0)+		; BPLCON3 color low
	IFEQ scs_center_bar
		move.w	a5,(a0)+	; COLOR00
		move.w	#color00_low_bits,(a0)+
	ENDC
	move.l	d2,(a0)+		; COLOR01
	move.l	d4,(a0)+		; COLOR02
	move.l	d5,(a0)+		; COLOR05
	move.l	a6,(a0)+		; COLOR06
	COP_MOVEQ 0,NOOP
	cmp.l	#(((CL_Y_WRAP<<24)|(((cl2_vp2_HSTART/4)*2)<<16))|$10000)|$fffe,d0 ; rasterline $ff ?
	bne.s	cl2_init_roller_skip
	subq.w	#LONGWORD_SIZE,a0
	COP_WAIT CL_X_WRAP,CL_Y_WRAP	; patch cl
cl2_init_roller_skip
	add.l	d6,d0			; next line in cl
	dbf	d7,cl2_init_roller_loop
	movem.l (a7)+,a4-a6
	rts


	COP_INIT_COPINT cl2,cl2_HSTART,cl2_VSTART


	CNOP 0,4
cl2_vp2_set_plane_ptrs
	MOVEF.L (extra_pf2_1_plane_x_offset/8)+(extra_pf2_1_plane_y_offset*extra_pf2_plane_width*extra_pf2_depth),d1 ; 2nd half
	move.l	cl2_construction2(a3),a0
	move.l	extra_pf2(a3),a2
	lea	cl2_extension5_entry+cl2_ext5_BPL2PTH+WORD_SIZE(a0),a1
	ADDF.W	cl2_extension5_entry+cl2_ext5_BPL1PTH+WORD_SIZE,a0
	moveq	#extra_pf2_depth-1,d7
cl2_vp2_set_plane_ptrs_loop1
	move.l	(a2)+,d0		; bitplane address
	add.l	d1,d0			; offset
	move.w	d0,4(a0)		; BPLxPTL
	swap	d0			; high
	move.w	d0,(a0)			; BPLxPTH
	ADDF.W	QUADWORD_SIZE*2,a0
	dbf	d7,cl2_vp2_set_plane_ptrs_loop1

	MOVEF.L (extra_pf2_2_plane_x_offset/8)+(extra_pf2_2_plane_y_offset*extra_pf2_plane_width*extra_pf2_depth),d1 ; 2nd half
	move.l	extra_pf2(a3),a2
	moveq	#extra_pf2_depth-1,d7
cl2_vp2_set_plane_ptrs_loop2
	move.l	(a2)+,d0		; bitplane address
	add.l	d1,d0			; offset
	move.w	d0,4(a1)		; BPLxPTL
	swap	d0			; high
	move.w	d0,(a1)			; BPLxPTH
	ADDF.W	QUADWORD_SIZE*2,a1
	dbf	d7,cl2_vp2_set_plane_ptrs_loop2
	rts

	CNOP 0,4
scs_set_vert_compression
	MOVEF.W	sine_table_length1/4,d1	; 1st y angle 90°
	moveq	#scs_roller_y_radius*2,d3
	moveq	#scs_roller_y_center,d4
	MOVEF.W (sine_table_length1/4)*3,d5 ; 270°
	moveq	#cl2_extension6_size,d6
	lea	sine_table(pc),a0	
	move.l	cl2_construction2(a3),a1
	ADDF.W	cl2_extension6_entry,a1 
	moveq	#extra_pf2_plane_width*extra_pf2_depth,d7
scs_set_vert_compression_loop
	move.w	2(a0,d1.w*4),d0		; sin(w)
	muls.w	d3,d0			; yr*sin(w)
	swap	d0			; y'=(yr*sin(w))/2^15
	add.w	d4,d0			; y' + y center
	mulu.w	d6,d0			; y offsert in cl
	add.w	d7,cl2_ext6_BPL1MOD+WORD_SIZE(a1,d0.l) ; BPL1MOD
	addq.w	#scs_roller_y_angle_step,d1
	sub.w	d7,cl2_ext6_BPL2MOD+WORD_SIZE(a1,d0.l) ; BPL2MOD
	cmp.w	d5,d1			; 270° ?
	ble.s	scs_set_vert_compression_loop
	rts

	CNOP 0,4
scs_set_color_gradients
	movem.l a4-a5,-(a7)
	MOVEF.W color00_high_bits,d2
	MOVEF.W color00_low_bits,d3
	lea	scs_color_gradient_front(pc),a0
	lea	scs_color_gradient_back(pc),a1
	move.l	cl2_construction2(a3),a2 
	ADDF.W	cl2_extension6_entry+cl2_ext6_COLOR00_high+WORD_SIZE,a2
	lea	scs_color_gradient_outline(pc),a4
	move.w	#cl2_extension6_size,a5
	moveq	#vp2_visible_lines_number-1,d7 ; number of color values
scs_set_color_gradients_loop
	move.w	d2,(a2)			; color high
	move.w	d3,cl2_ext6_COLOR00_low-cl2_ext6_COLOR00_high(a2) ; color low
	move.w	(a0)+,cl2_ext6_COLOR01_high-cl2_ext6_COLOR00_high(a2) ; color high
	move.w	(a0)+,cl2_ext6_COLOR01_low-cl2_ext6_COLOR00_high(a2) ; color low
	move.w	(a1)+,cl2_ext6_COLOR05_high-cl2_ext6_COLOR00_high(a2) ; color high
	move.w	(a1)+,cl2_ext6_COLOR05_low-cl2_ext6_COLOR00_high(a2) ; color low
	move.l	(a4)+,d0
	move.w	d0,cl2_ext6_COLOR02_low-cl2_ext6_COLOR00_high(a2) ; color low
	move.w	d0,cl2_ext6_COLOR06_low-cl2_ext6_COLOR00_high(a2) ; color low
	swap	d0			; high
	move.w	d0,cl2_ext6_COLOR02_high-cl2_ext6_COLOR00_high(a2) ; color high
	add.l	a5,a2			; next line in cl
	move.w	d0,(cl2_ext6_COLOR06_high-cl2_ext6_COLOR00_high)-cl2_extension6_size(a2) ; color high
	dbf	d7,scs_set_color_gradients_loop
	movem.l (a7)+,a4-a5
	rts

	IFEQ scs_pipe_effect
		CNOP 0,4
scs_set_pipe
		moveq	#scs_pipe_shift_x_center,d2
		MOVEF.W $ff,d3		; scroll mask H0-H7
		lea	scs_pipe_shift_x_table(pc),a0
		move.l	cl2_construction2(a3),a1
		ADDF.W	cl2_extension6_entry+cl2_ext6_BPLCON1+WORD_SIZE,a1
		move.w	#cl2_extension6_size,a2
		moveq	#vp2_visible_lines_number-1,d7
scs_set_pipe_loop
		move.w	(a0)+,d0	; x shift
		moveq	#scs_pipe_shift_x_center,d1
		sub.w	d0,d1		; x center-x'
		add.w	d2,d0		; x center+x'
		DUALPF_SOFTSCROLL_64PIXEL_LORES d1,d0,d3
		move.w	d1,(a1)		; BPLCON1
		add.l	a2,a1		; next line in cl
		dbf	d7,scs_set_pipe_loop
		rts
	ENDC


	COPY_COPPERLIST cl2,2


	CNOP 0,4
main
	bsr.s	no_sync_routines
	bra.s	beam_routines


	CNOP 0,4
no_sync_routines
	rts


	CNOP 0,4
beam_routines
	bsr	wait_copint
	bsr	swap_second_copperlist
	bsr	spr_swap_structures
	bsr	spr_set_sprite_ptrs
	bsr	scs_horiz_scrolltext
	bsr	scs_horiz_scroll
	bsr	hcs_get_bplcon1_shifts
	bsr	scs_vert_scroll
	bsr	hcs_get_horiz_step
	bsr	hcs_get_horiz_speed
	bsr	horiz_char_scrolling
	bsr	scs_set_color_gradients
	bsr	scs_char_vert_scroll
	bsr	radius_fader_in
	bsr	radius_fader_out
	bsr	sb232_get_y_coords
	bsr	sb36_get_yz_coords
	bsr	sb36_set_background_bars
	bsr	sb36_set_foreground_bars
	bsr	scs_set_center_bar
	bsr	hsi_shrink_logo_x_size
	bsr	move_spaceship_left
	bsr	move_spaceship_right
	bsr	image_fader_in
	bsr	image_fader_out
	bsr	if_rgb8_copy_color_table
	bsr	sprite_fader_in
	bsr	sprite_fader_out
	bsr	sprf_rgb8_copy_color_table
	bsr	bar_fader_in
	bsr	bar_fader_out
	bsr	bf_rgb8_convert_colors
	bsr	control_counters
	bsr	mouse_handler
	tst.w	stop_fx_active(a3)
	bne	beam_routines
	rts


	SWAP_COPPERLIST cl2,2


	SWAP_SPRITES spr,spr_swap_number


	SET_SPRITES spr,spr_swap_number


	CNOP 0,4
scs_horiz_scrolltext
	tst.w	scs_enabled(a3)
	bne	scs_horiz_scrolltext_quit
	tst.w	scs_text_move_active(a3)
	bne.s	scs_horiz_scrolltext_quit
	move.w	scs_text_char_x_shift(a3),d2
	addq.w	#scs_horiz_scroll_speed,d2
	cmp.w	#scs_text_char_x_shift_max,d2
	blt.s	scs_horiz_scrolltext_skip3
	bsr.s	scs_get_new_char_image	; d0 = character
	MOVEF.L scs_text_char_x_restart/8,d1
	move.w	scs_text_char_y_offset(a3),d3
	add.w	d3,d1			; x offset + y offset
	move.l	extra_pf2(a3),a0
	add.l	(a0),d1			; add playfield address
	move.w	#DMAF_BLITHOG+DMAF_SETCLR,DMACON-DMACONR(a6)
	WAITBLIT
	move.l	#(BC0F_SRCA+BC0F_DEST+ANBNC+ANBC+ABNC+ABC)<<16,BLTCON0-DMACONR(a6) ; minterm D=A
	moveq	#-1,d5
	move.l	d5,BLTAFWM-DMACONR(a6)
	move.l	d0,BLTAPT-DMACONR(a6)	; character image
	move.l	d1,BLTDPT-DMACONR(a6)	; playfield write
	move.l	#((scs_image_plane_width-scs_text_char_width)<<16)+(extra_pf2_plane_width-scs_text_char_width),BLTAMOD-DMACONR(a6) ; A&D moduli
	move.w	#((scs_text_char_y_size/2)*scs_text_char_depth*64)+(scs_text_char_x_size/WORD_BITS),BLTSIZE-DMACONR(a6)
	WAITBLIT
	cmp.w	#(scs_vert_scroll_window_y_size-(scs_text_char_y_size/2))*extra_pf2_plane_width*extra_pf2_depth,d3 ; character image outside playfield ?
	blt.s	scs_horiz_scrolltext_skip1
	moveq	#scs_text_char_x_restart/8,d1
	add.l	(a0),d1			; add playfield address
	move.l	d1,BLTDPT-DMACONR(a6)	; playfield write
scs_horiz_scrolltext_skip1
	move.w	#((scs_text_char_y_size/2)*scs_text_char_depth*64)+(scs_text_char_x_size/WORD_BITS),BLTSIZE-DMACONR(a6)
	sub.w	#(scs_text_char_y_size/scs_horiz_scroll_speed)*extra_pf2_plane_width*extra_pf2_depth,d3
	bpl.s	scs_horiz_scrolltext_skip2
	move.w	#(scs_horiz_scroll_window_y_size-(scs_text_char_y_size/2))*extra_pf2_plane_width*extra_pf2_depth,d3 ; resert y offset
scs_horiz_scrolltext_skip2
	move.w	d3,scs_text_char_y_offset(a3)
	moveq	#0,d2			; resert x shift
scs_horiz_scrolltext_skip3
	move.w	d2,scs_text_char_x_shift(a3)
scs_horiz_scrolltext_quit
	rts


	GET_NEW_char_IMAGE.W scs,scs_check_control_codes,NORESTART



; Input
; d0.b	ASCII-Code
; Result
; d0.l	Rückgabewert
	CNOP 0,4
scs_check_control_codes
	cmp.b	#"¹",d0
	beq.s	scs_start_sine_bars232
	cmp.b	#"²",d0
	beq.s	scs_start_sine_bars36
	cmp.b	#ASCII_CTRL_F,d0
	beq.s	scs_start_radius_fader_out
	cmp.b	#ASCII_CTRL_A,d0
	beq.s	scs_start_spaceship
	cmp.b	#ASCII_CTRL_C,d0
	beq	scs_start_corkscrew
	cmp.b	#ASCII_CTRL_N,d0
	beq	scs_start_normal_scrolltext
	cmp.b	#ASCII_CTRL_P,d0
	beq	scs_pause_scrolltext
	cmp.b	#ASCII_CTRL_S,d0
	beq	scs_stop_scrolltext
	rts
	CNOP 0,4
scs_start_sine_bars232
	move.w	#FALSE,sb36_active(a3)
	clr.w	sb232_y_angle(a3)	; 0°
	clr.w	sb232_active(a3)
	clr.w	rfi_active(a3)
	move.w	#1,rfi_delay_counter(a3) ; activate counter
	moveq	#RETURN_OK,d0
	rts
	CNOP 0,4
scs_start_sine_bars36
	move.w	#FALSE,sb232_active(a3)
	clr.w	sb36_y_angle(a3)	; 0°
	clr.w	sb36_active(a3)
	clr.w	rfi_active(a3)
	move.w	#1,rfi_delay_counter(a3) ; activate counter
	moveq	#RETURN_OK,d0
	rts
	CNOP 0,4
scs_start_radius_fader_out
	clr.w	rfo_active(a3)
	move.w	#1,rfo_delay_counter(a3) ; activate counter
	moveq	#RETURN_OK,d0
	rts
	CNOP 0,4
scs_start_spaceship
	tst.w	msr_active(a3)		; spaceship movement to right ?
	bne.s	scs_start_spaceship_skip
	move.w	#sine_table_length2/2,msr_x_angle(a3) ; 180°
scs_start_spaceship_skip
	bsr	msl_copy_bitmaps
	clr.w	msl_active(a3)		; start movement to left
	move.w	#sine_table_length2/4,msl_x_angle(a3) ; 90°
	moveq	#RETURN_OK,d0
	rts
	CNOP 0,4
scs_start_corkscrew
	move.w	#scs_vert_scroll_speed1,scs_variable_vert_scroll_speed(a3)
	moveq	#RETURN_OK,d0
	rts
	CNOP 0,4
scs_start_normal_scrolltext
	move.w	#scs_vert_scroll_speed2,scs_variable_vert_scroll_speed(a3)
	moveq	#RETURN_OK,d0
	rts
	CNOP 0,4
scs_pause_scrolltext
	move.w	#FALSE,scs_text_move_active(a3) ; pause text
	move.w	#scs_text_delay,scs_text_delay_counter(a3)
	moveq	#RETURN_OK,d0
	rts
	CNOP 0,4
scs_stop_scrolltext
	move.w	#FALSE,scs_enabled(a3)	; stop text
	tst.w	exit_active(a3)		; quit intro ?
	bne.s	scs_stop_scrolltext_quit
	clr.w	pt_music_fader_active(a3)
	move.w	#if_rgb8_colors_number*3,if_rgb8_colors_counter(a3)
	clr.w	ifo_rgb8_active(a3)
	clr.w	if_rgb8_copy_colors_active(a3)
	move.w	#sprf_rgb8_colors_number*3,sprf_rgb8_colors_counter(a3)
	clr.w	sprfo_rgb8_active(a3)
	clr.w	sprf_rgb8_copy_colors_active(a3)
	move.w	#bf_rgb8_colors_number*3,bf_rgb8_colors_counter(a3)
	clr.w	bf_rgb8_convert_colors_active(a3)
	clr.w	bfo_rgb8_active(a3)
scs_stop_scrolltext_quit
	moveq	#RETURN_OK,d0
	rts


	CNOP 0,4
scs_horiz_scroll
	move.w	#DMAF_BLITHOG,DMACON-DMACONR(a6)
	tst.w	scs_enabled(a3)
	bne.s	scs_no_horiz_scroll
	tst.w	scs_text_move_active(a3)
	bne.s	scs_no_horiz_scroll
	move.l	extra_pf2(a3),a0
	move.l	(a0),a0
	add.l	#(scs_text_x_position/8)+(scs_text_y_position*extra_pf2_plane_width*extra_pf2_depth),a0 ; skip 48 pixel in destination
	WAITBLIT
	move.l	#((-scs_horiz_scroll_speed<<12)+BC0F_SRCA+BC0F_DEST+ANBNC+ANBC+ABNC+ABC)<<16,BLTCON0-DMACONR(a6) ; minterm D=A
	moveq	#-1,d0
	move.l	d0,BLTAFWM-DMACONR(a6)
	move.l	a0,BLTDPT-DMACONR(a6)	; destination
	addq.w	#WORD_SIZE,a0		; skip 16 pixel
	move.l	a0,BLTAPT-DMACONR(a6)	; source
	move.l	#((extra_pf2_plane_width-scs_horiz_scroll_window_width)<<16)+(extra_pf2_plane_width-scs_horiz_scroll_window_width),BLTAMOD-DMACONR(a6) ; A&D moduli
	move.w	#(scs_horiz_scroll_window_y_size*scs_horiz_scroll_window_depth*64)+(scs_horiz_scroll_window_x_size/WORD_BITS),BLTSIZE-DMACONR(a6)
scs_no_horiz_scroll
	rts


	CNOP 0,4
hcs_get_bplcon1_shifts
	move.l	a4,-(a7)
	moveq	#hsi_shift_values_number/2,d3 ; center
	move.w	hsi_x_radius_angle(a3),d4 ; 1st x radius angle
	move.w	d4,d0
	addq.b	#hsi_x_radius_angle_speed,d0
	move.w	d0,hsi_x_radius_angle(a3) 
	move.w	hsi_x_radius_angle_step(a3),d5
	lea	sine_table(pc),a0	
	lea	hsi_radius_table(pc),a1
	lea	hsi_shift_table(pc),a2
	lea	hsi_bplcon1_table+BYTE_SIZE(pc),a4
	moveq	#hsi_lines_number-1,d7
hcs_get_bplcon1_shifts_loop1
	move.l	(a0,d4.w*4),d1		; sin(w)
	MULUF.L hsi_x_radius*2,d1,d0	; xr'=(xr*sin(w))/2^15
	swap	d1
	add.b	d5,d4			; next x radius angle
	addq.w	#hsi_shift_values_number/4,d1 ; xr' + x center
	moveq	#(sine_table_length1/4)-(2*hsi_x_angle_step),d2 ; 1st x angle
	neg.w	d1
	moveq	#cl2_display_width-1,d6	; number of entries in destination table
hcs_get_bplcon1_shifts_loop2
	move.w	d1,d0			; -cos(w)
	muls.w	2(a0,d2.w*4),d0		; x'=(xr'*(-cos(w)))/2^15
	add.l	d0,d0
	swap	d0
	add.w	d3,d0			; x' + x center
	subq.w	#1,d0			; count starts at 0
	move.b	(a2,d0.w),(a4)		; copy x shift
	addq.b	#hsi_x_angle_step,d2
	addq.w	#WORD_SIZE,a4		; next entry
	dbf	d6,hcs_get_bplcon1_shifts_loop2
	dbf	d7,hcs_get_bplcon1_shifts_loop1
	move.l	(a7)+,a4
	rts


	CNOP 0,4
scs_vert_scroll
	tst.w	scs_enabled(a3)
	bne.s	scs_no_vert_scroll
	move.l	extra_pf2(a3),a0
	move.l	(a0),a0
	add.l	#((scs_text_x_position+16)/8)+(scs_text_y_position*extra_pf2_plane_width*extra_pf2_depth),a0 ; skip 64 pixel in destination
	move.l	extra_pf2(a3),a2
	move.l	(a2),a2
	lea	(vp2_pf_pixel_per_datafetch/8)+(scs_vert_scroll_window_y_size*extra_pf2_plane_width*extra_pf2_depth)(a2),a1 ; last line, skip 64 pixel
; vertikaler Umlaufeffekt 
	move.w	#DMAF_BLITHOG+DMAF_SETCLR,DMACON-DMACONR(a6)
	WAITBLIT
	move.w	#BC0F_SRCA+BC0F_DEST+ANBNC+ANBC+ABNC+ABC,BLTCON0-DMACONR(a6) ; minterm D=A
	move.l	a0,BLTAPT-DMACONR(a6)	; source
	move.l	a1,BLTDPT-DMACONR(a6)	; destination
	move.l	#((extra_pf2_plane_width-(scs_vert_scroll_window_width))<<16)+(extra_pf2_plane_width-scs_vert_scroll_window_width),BLTAMOD-DMACONR(a6) ; A&D moduli
	move.w	scs_variable_vert_scroll_speed(a3),d0
	MULUF.W scs_vert_scroll_window_depth*64,d0,d1
	or.w	#scs_vert_scroll_window_x_size/16,d0
	move.w	d0,BLTSIZE-DMACONR(a6)
; Laufschrift vertikal bewegen 
	move.w	scs_variable_vert_scroll_speed(a3),d0
	MULUF.W extra_pf2_plane_width*extra_pf2_depth,d0,d1
	lea	(vp2_pf_pixel_per_datafetch/8)(a2,d0.w),a0 ; 2nd or 3rd line, skip 64 pixel
	lea	(vp2_pf_pixel_per_datafetch/8)(a2),a1 ; 1st line, skip 64 pixel
	WAITBLIT
	move.w	#DMAF_BLITHOG,DMACON-DMACONR(a6)
	move.l	a0,BLTAPT-DMACONR(a6)	; source
	move.l	a1,BLTDPT-DMACONR(a6)	; estination
	move.w	#(scs_vert_scroll_window_y_size*scs_vert_scroll_window_depth*64)+(scs_vert_scroll_window_x_size/WORD_BITS),BLTSIZE-DMACONR(a6)
scs_no_vert_scroll
	rts


	CNOP 0,4
hcs_get_horiz_speed
	tst.w	hcs_get_horiz_speed_active(a3)
	bne.s	hcs_get_horiz_speed_quit
	move.w	hcs_horiz_speed_angle(a3),d2
	lea	sine_table(pc),a0
	move.l	(a0,d2.w*4),d0		; cos(w)
	MULUF.L hcs_horiz_speed_max*2*2,d0,d1 ; s'=(cos(w)*r)/2^15
	swap	d0
	add.w	#hcs_horiz_speed_max*2,d0 ; add center
	move.w	d0,hcs_horiz_speed(a3)
	addq.w	#hcs_horiz_speed_angle_speed,d2
	cmp.w	#sine_table_length1/2,d2 ; 180° ?
	ble.s	hcs_get_horiz_speed_skip
	move.w	#FALSE,hcs_get_horiz_speed_active(a3)
hcs_get_horiz_speed_skip
	move.w	d2,hcs_horiz_speed_angle(a3)
hcs_get_horiz_speed_quit
	rts


	CNOP 0,4
hcs_get_horiz_step
	tst.w	hcs_get_horiz_step_active(a3)
	bne.s	hcs_get_horiz_step_quit
	move.w	hcs_horiz_step_angle(a3),d2
	lea	sine_table(pc),a0
	move.l	(a0,d2.w*4),d0		; cos(w)
	MULUF.L hcs_horiz_step_max*2*2,d0,d1 ; s'=(cos(w)*r)/2^15
	swap	d0
	add.w	#(hcs_horiz_step_max*2)+1,d0 ; add center
	move.w	d0,hcs_horiz_step(a3)
	addq.w	#hcs_horiz_step_angle_speed,d2
	cmp.w	#sine_table_length1/2,d2 ; 180° ?
	ble.s	hcs_get_horiz_step_skip
	move.w	#FALSE,hcs_get_horiz_step_active(a3)
hcs_get_horiz_step_skip
	move.w	d2,hcs_horiz_step_angle(a3)
hcs_get_horiz_step_quit
	rts


	CNOP 0,4
horiz_char_scrolling
	movem.l a4-a6,-(a7)
	MOVEF.W FALSE_BYTE-SPRCTLF_SH2-SPRCTLF_SH0-SPRCTLF_SH1,d2 ; mask for SH0,SH1,SH2 bits
	move.w	hcs_horiz_speed(a3),d3
	moveq	#0,d4			; to store the X bit
	IFNE hcs_quick_x_max_restart
		move.w	#hcs_x_max,d5
	ENDC
	lea	spr_ptrs_construction+(hcs_z_planes_number*QUADWORD_SIZE)(pc),a2 ; last sprite
	IFNE hcs_quick_x_max_restart
		move.w	#hcs_horiz_restart,a4
	ENDC
	lea	hcs_objects_x_coords(pc),a5
	move.w	#spr2_extension1_size,a6
	moveq	#hcs_z_planes_number-1,d7
hcs_horiz_ballscrolling_loop1
	move.l	-(a2),a1		; 2nd sprite structure
	addq.w	#BYTE_SIZE,a1		; SPRxPOS low
	move.l	-(a2),a0		; 1st  sprite structure
	addq.w	#1,a0			; SPRxPOS low
	moveq	#hcs_objects_per_sprite_number-1,d6
hcs_horiz_ballscrolling_loop2
	move.b	spr_pixel_per_datafetch/8(a0),d1 ; SPRxCTL low
	and.b	d2,d1			; clear SH0,SH1,SH2 bits
	move.w	(a5),d0			; x
	add.w	d3,d0			; increase x by speed
	IFEQ hcs_quick_x_max_restart
		and.w	d5,d0		; remove overflow
	ELSE
	cmp.w	d5,d0			; x max ?
	ble.s	hcs_horiz_ballscrolling_skip
	sub.w	a4,d0			; reset x
hcs_horiz_ballscrolling_skip
	ENDC
	move.w	d0,(a5)+		
	lsl.w	#5,d0			; SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3 SH2 SH1 SH0 --- --- --- --- ---
	add.b	d0,d0			;  SH1 SH0 --- --- --- --- --- ---
	addx.b	d4,d1			;  --- --- --- --- --- SV8 EV8 SH2
	lsr.b	#3,d0			;  --- --- --- SH1 SH0 --- --- ---
	or.b	d0,d1			;  --- --- --- SH1 SH0 SV8 EV8 SH2
	move.b	d1,spr_pixel_per_datafetch/8(a0) ; SPRxCTL low
	lsr.w	#8,d0			;  --- --- --- --- --- --- --- --- SH10 SH9 SH8 SH7 SH6 SH5 SH4 SH3
	move.b	d0,(a0)			; SPRxPOS low
	or.b	#SPRCTLF_ATT,d1		;  ATT --- --- SH1 SH0 SV8 EV8 SH2
	move.b	d0,(a1)			; SPRxPOS low
	add.l	a6,a0			; next sprite structure
	move.b	d1,spr_pixel_per_datafetch/8(a1) ; SPRxCTL low
	add.l	a6,a1			; next sprite structure
	dbf	d6,hcs_horiz_ballscrolling_loop2
	add.w	hcs_horiz_step(a3),d3	; speed of next plane
	dbf	d7,hcs_horiz_ballscrolling_loop1
	movem.l (a7)+,a4-a6
	rts


	CNOP 0,4
scs_char_vert_scroll
	tst.w	scs_enabled(a3)
	bne.s	scs_char_vert_scroll_quit
	move.l	extra_pf2(a3),a2
	move.l	(a2),a2
	lea	(extra_pf2_x_size-vp2_pf_pixel_per_datafetch)/8(a2),a0 ; 1st line, right border 64 pixel substracted
	lea	((extra_pf2_x_size-vp2_pf_pixel_per_datafetch)/8)+(scs_vert_scroll_window_y_size*extra_pf2_plane_width*extra_pf2_depth)(a2),a1 ; last line, right border 64 pixel substracted
; Vertical wrapping
	move.w	#DMAF_BLITHOG+DMAF_SETCLR,DMACON-DMACONR(a6)
	WAITBLIT
	move.w	#BC0F_SRCA+BC0F_DEST+ANBNC+ANBC+ABNC+ABC,BLTCON0-DMACONR(a6) ; minterm D=A
	move.l	a0,BLTAPT-DMACONR(a6)	; source
	move.l	a1,BLTDPT-DMACONR(a6)	; destination
	move.l	#((extra_pf2_plane_width-scs_text_char_width)<<16)+(extra_pf2_plane_width-scs_text_char_width),BLTAMOD-DMACONR(a6) ; A&D moduli
	move.w	#(scs_text_char_vert_speed*scs_vert_scroll_window_depth*64)+(scs_text_char_x_size/WORD_BITS),BLTSIZE-DMACONR(a6)
; Buchstaben vertikal bewegen 
	lea	((extra_pf2_x_size-vp2_pf_pixel_per_datafetch)/8)+(scs_text_char_vert_speed*extra_pf2_plane_width*extra_pf2_depth)(a2),a0 ; 2nd line, right border 64 pixel substracted
	lea	(extra_pf2_x_size-vp2_pf_pixel_per_datafetch)/8(a2),a1 ; 1st line, right border 64 pixel substracted
	WAITBLIT
	move.w	#DMAF_BLITHOG,DMACON-DMACONR(a6)
	move.l	a0,BLTAPT-DMACONR(a6)	; source
	move.l	a1,BLTDPT-DMACONR(a6)	; destination
	move.w	#(scs_vert_scroll_window_y_size*scs_vert_scroll_window_depth*64)+(scs_text_char_x_size/WORD_BITS),BLTSIZE-DMACONR(a6)
scs_char_vert_scroll_quit
	rts


	CNOP 0,4
sb232_get_y_coords
	movem.l a4-a6,-(a7)
	tst.w	sb232_active(a3)
	bne	sb232_get_y_coords_quit
	tst.w	sb_variable_y_radius(a3) ; y radius = 0  ?
	beq	sb232_get_y_coords_quit
	move.w	sb232_y_radius_angle(a3),d3 ; 1st y radius angle
	move.w	d3,d0
	move.w	sb232_y_angle(a3),d4	; 1st y angle
	addq.b	#sb232_y_radius_angle_speed,d0
	move.w	d0,sb232_y_radius_angle(a3)
	move.w	d4,d0
	addq.b	#sb232_y_angle_speed,d0
	move.w	d0,sb232_y_angle(a3) 
	lea	sine_table(pc),a0	
	move.w	#sb232_y_center,a1
	move.l	cl2_construction2(a3),a5 
	ADDF.W	cl2_extension6_entry+cl2_ext6_COLOR00_high+WORD_SIZE,a5
	move.w	#cl2_extension6_size,a6
	moveq	#sb232_bars_number-1,d7
sb232_get_y_coords_loop1
	move.w	2(a0,d3.w*4),d0		; sin(w)
	muls.w	sb_variable_y_radius(a3),d0 ; yr'=(yr*sin(w))/2^15
	swap	d0
	addq.b	#sb232_y_radius_angle_step,d3
	muls.w	2(a0,d4.w*4),d0		; y'=(yr'*sin(w))/2^15
	add.l	d0,d0
	swap	d0
	ADDF.B	sb232_y_distance,d4	; y distance to next bar
	add.w	a1,d0			; y' + y center
	MULUF.W cl2_extension6_size/4,d0,d1 ; y offset in cl
	lea	(a5,d0.w*4),a2
	lea	scs_bar_color_table(pc),a4
	moveq	#sb_bar_height-1,d6
sb232_get_y_coords_loop2
	move.l	(a4)+,d0
	move.w	d0,cl2_ext6_COLOR00_low-cl2_ext6_COLOR00_high(a2) ; color low
	move.w	d0,cl2_ext6_COLOR05_low-cl2_ext6_COLOR00_high(a2) ; color low
	move.w	d0,cl2_ext6_COLOR06_low-cl2_ext6_COLOR00_high(a2) ; color low
	swap	d0			; high
	move.w	d0,(a2)			; color high
	move.w	d0,cl2_ext6_COLOR05_high-cl2_ext6_COLOR00_high(a2) ; color high
	add.l	a6,a2			; next line in cl
	move.w	d0,(cl2_ext6_COLOR06_high-cl2_ext6_COLOR00_high)-cl2_extension6_size(a2) ; color high
	dbf	d6,sb232_get_y_coords_loop2
	dbf	d7,sb232_get_y_coords_loop1
sb232_get_y_coords_quit
	movem.l (a7)+,a4-a6
	rts


	CNOP 0,4
sb36_get_yz_coords
	move.l	a4,-(a7)
	tst.w	sb36_active(a3)
	bne.s	sb36_get_yz_coords_quit
	tst.w	sb_variable_y_radius(a3)
	beq.s	sb36_get_yz_coords_quit
	move.w	sb36_y_angle(a3),d2	; 1st y angle
	move.w	d2,d0		
	move.w	sb36_y_distance_angle(a3),d4 ; 1st y distance angle
	addq.b	#sb36_y_angle_speed,d0
	move.w	d0,sb36_y_angle(a3) 
	move.w	d4,d0
	addq.b	#sb36_y_distance_speed,d0
	move.w	d0,sb36_y_distance_angle(a3) 
	lea	sine_table(pc),a0
	lea	sb36_yz_coords(pc),a1
	move.w	#sb36_y_center,a2
	move.w	#sb36_y_distance_center,a4
	moveq	#sb36_bars_number-1,d7
sb36_get_yz_coords_loop
	moveq	#-(sine_table_length1/4),d1 ; - 90°
	move.w	2(a0,d2.w*4),d0		; sin(w)
	add.w	d2,d1			; y angle - 90°
	ext.w	d1
	move.w	d1,(a1)+		; z vector
	muls.w	sb_variable_y_radius(a3),d0 ; y'=(yr*sin(w))/2^15
	swap	d0
	add.w	a2,d0			; y' + y center
	MULUF.W cl2_extension6_size/4,d0,d1 ; y offset in cl
	move.l	(a0,d4.w*4),d3		; sin(w)
	MULUF.L sb36_y_distance_radius*2,d3,d1 ; y'=(yr*sin(w))/2^15
	swap	d3
	move.w	d0,(a1)+		; y coordinate
	add.w	a4,d3			; y' + y distance center
	addq.b	#sb36_y_distance_step1,d4
	add.b	d3,d2			; y distance to next bar
	dbf	d7,sb36_get_yz_coords_loop
sb36_get_yz_coords_quit
	move.l	(a7)+,a4
	rts


	CNOP 0,4
sb36_set_background_bars
	move.l	a4,-(a7)
	tst.w	sb36_active(a3)
	bne.s	sb36_set_background_bars_quit
	tst.w	sb_variable_y_radius(a3) ; y radius = 0 ?
	beq.s	sb36_set_background_bars_quit
	MOVEF.L cl2_extension6_size,d5
	lea	sb36_yz_coords(pc),a0
	move.l	cl2_construction2(a3),a2 
	ADDF.W	cl2_extension6_entry+cl2_ext6_COLOR00_high+WORD_SIZE,a2
	moveq	#sb36_bars_number-1,d7
sb36_set_background_bars_loop1
	move.l	(a0)+,d0		; high word: z vector, low word: y
	bmi.s	sb36_set_background_bars_skip
	lea	scs_bar_color_table(pc),a1
	lea	(a2,d0.w*4),a4		; y offset in cl
	moveq	#sb_bar_height-1,d6
sb36_set_background_bars_loop2
	move.l	(a1)+,d0
	move.w	d0,cl2_ext6_COLOR00_low-cl2_ext6_COLOR00_high(a4) ; color low
	move.w	d0,cl2_ext6_COLOR05_low-cl2_ext6_COLOR00_high(a4) ; color low
	move.w	d0,cl2_ext6_COLOR06_low-cl2_ext6_COLOR00_high(a4) ; color low
	swap	d0			; high
	move.w	d0,(a4)			; color high
	move.w	d0,cl2_ext6_COLOR05_high-cl2_ext6_COLOR00_high(a4) ; color high
	add.l	d5,a4			; next line in cl
	move.w	d0,(cl2_ext6_COLOR06_high-cl2_ext6_COLOR00_high)-cl2_extension6_size(a4) ; color high
	dbf	d6,sb36_set_background_bars_loop2
sb36_set_background_bars_skip
	dbf	d7,sb36_set_background_bars_loop1
sb36_set_background_bars_quit
	move.l	(a7)+,a4
	rts


	CNOP 0,4
sb36_set_foreground_bars
	move.l	a4,-(a7)
	tst.w	sb36_active(a3)
	bne.s	sb36_set_foreground_bars_quit
	tst.w	sb_variable_y_radius(a3) ; y radius = 0 ?
	beq.s	sb36_set_foreground_bars_quit
	MOVEF.L cl2_extension6_size,d5
	lea	sb36_yz_coords(pc),a0
	move.l	cl2_construction2(a3),a2 
	ADDF.W	cl2_extension6_entry+cl2_ext6_COLOR00_high+WORD_SIZE,a2
	moveq	#sb36_bars_number-1,d7
sb36_set_foreround_bars_loop1
	move.l	(a0)+,d0		; high word: z vector, low word: y
	bpl.s	sb36_set_foreground_bars_skip
sb36_set_foreground_bar
	lea	scs_bar_color_table(pc),a1
	lea	(a2,d0.w*4),a4		; y offset in cl
	moveq	#sb_bar_height-1,d6
sb36_set_foreround_bars_loop2
	move.l	(a1)+,d0
	move.w	d0,cl2_ext6_COLOR00_low-cl2_ext6_COLOR00_high(a4) ; color low
	move.w	d0,cl2_ext6_COLOR05_low-cl2_ext6_COLOR00_high(a4) ; color low
	move.w	d0,cl2_ext6_COLOR06_low-cl2_ext6_COLOR00_high(a4) ; color low
	swap	d0			; high
	move.w	d0,(a4)			; color high
	move.w	d0,cl2_ext6_COLOR05_high-cl2_ext6_COLOR00_high(a4) ; color high
	add.l	d5,a4			; next line in cl
	move.w	d0,(cl2_ext6_COLOR06_high-cl2_ext6_COLOR00_high)-cl2_extension6_size(a4) ; color high
	dbf	d6,sb36_set_foreround_bars_loop2
sb36_set_foreground_bars_skip
	dbf	d7,sb36_set_foreround_bars_loop1
sb36_set_foreground_bars_quit
	move.l	(a7)+,a4
	rts


	CNOP 0,4
scs_set_center_bar
	tst.w	sb_variable_y_radius(a3)
	bne.s	scs_set_center_bar_quit
	lea	scs_bar_color_table(pc),a0
	move.l	cl2_construction2(a3),a1 
	ADDF.W	(cl2_extension6_entry+cl2_ext6_COLOR00_high+WORD_SIZE)+(((vp2_visible_lines_number-scs_center_bar_height)/2)*cl2_extension6_size),a1 ; y centering
	move.w	#cl2_extension6_size,a2
	moveq	#scs_center_bar_height-1,d7
scs_set_center_bar_loop
	move.l	(a0)+,d0
	move.w	d0,cl2_ext6_COLOR00_low-cl2_ext6_COLOR00_high(a1) ; color low
	move.w	d0,cl2_ext6_COLOR05_low-cl2_ext6_COLOR00_high(a1) ; color low
	move.w	d0,cl2_ext6_COLOR06_low-cl2_ext6_COLOR00_high(a1) ; color low
	swap	d0			; high
	move.w	d0,(a1)			; color high
	move.w	d0,cl2_ext6_COLOR05_high-cl2_ext6_COLOR00_high(a1) ; color high
	add.l	a2,a1			; next line in cl
	move.w	d0,(cl2_ext6_COLOR06_high-cl2_ext6_COLOR00_high)-cl2_extension6_size(a1) ; color high
	dbf	d7,scs_set_center_bar_loop
scs_set_center_bar_quit
	rts


	CNOP 0,4
hsi_shrink_logo_x_size
	MOVEF.W $ff,d2			; scroll mask H0-H7
	lea	hsi_bplcon1_table(pc),a0
	move.l	cl2_construction2(a3),a1
	move.w	(a0)+,d0
	PF_SOFTSCROLL_64PIXEL_LORES d0,d1,d2
	move.w	d0,cl2_extension2_entry+cl2_ext2_BPLCON1+WORD_SIZE(a1)
	ADDF.W	cl2_extension3_entry+cl2_ext3_BPLCON1_1+WORD_SIZE,a1
	moveq	#hsi_lines_number-1,d7
hsi_shrink_logo_x_size_loop1
	moveq	#cl2_display_width-1,d6	; number of columns
hsi_shrink_logo_x_size_loop2
	move.w	(a0)+,d0		; x shift
	PF_SOFTSCROLL_64PIXEL_LORES d0,d1,d2
	move.w	d0,(a1)			; BPLCON1
	addq.w	#LONGWORD_SIZE,a1
	dbf	d6,hsi_shrink_logo_x_size_loop2
	addq.w	#LONGWORD_SIZE,a1	; skip CWAIT
	dbf	d7,hsi_shrink_logo_x_size_loop1
	rts


	CNOP 0,4
move_spaceship_left
	tst.w	msl_active(a3)
	bne.s	move_spaceship_left_quit
	move.w	msl_x_angle(a3),d2
	lea	sine_table_512(pc),a0
	move.w	(a0,d2.w*2),d1		; cos(w)
	muls.w	#ms_x_radius*SHIRES_PIXEL_FACTOR*2,d1 ; x'=(cos(w)*rx)/2^15
	swap	d1
	add.w	#ms_x_center*SHIRES_PIXEL_FACTOR,d1
	addq.w	#msl_x_angle_speed,d2
	cmp.w	#sine_table_length2/2,d2 ; 180° ?
	ble.s	move_spaceship_left_skip
	move.w	#FALSE,msl_active(a3)
	bsr	msr_copy_bitmaps
	clr.w	msr_active(a3)
	move.w	#sine_table_length2/4,msr_x_angle(a3) ; 90°
	rts
	CNOP 0,4
move_spaceship_left_skip
	move.w	d2,msl_x_angle(a3)
	move.w	#display_window_hstop*SHIRES_PIXEL_FACTOR,d0 ; x
	sub.w	d1,d0			; HSTART: x centering
	MOVEF.W msl_spaceship_y_position,d1 ; VSTART
	moveq	#ms_image_y_size,d2
	add.w	d1,d2			; VSTOP
	lea	spr_ptrs_construction(pc),a2
	move.l	(a2)+,a0		; 1st sprite structure
	ADDF.W	spr0_extension2_entry,a0
	move.l	(a2),a1			; 2nd sprite structure
	ADDF.W	spr1_extension2_entry,a1
	SET_SPRITE_POSITION d0,d1,d2
	move.w	d1,(a0)			; SPRxPOS
	move.w	d2,spr_pixel_per_datafetch/8(a0) ; SPRxCTL
	move.w	d1,(a1)			; SPRxPOS
	or.b	#SPRCTLF_ATT,d2
	move.w	d2,spr_pixel_per_datafetch/8(a1) ; SPRxCTL
move_spaceship_left_quit
	rts


	CNOP 0,4
msl_copy_bitmaps
	lea	msl_image_data,a2
	bra	ms_copy_image_data


	CNOP 0,4
move_spaceship_right
	tst.w	msr_active(a3)
	bne.s	move_spaceship_right_quit
	move.w	msr_x_angle(a3),d2
	lea	sine_table_512(pc),a0
	move.w	(a0,d2.w*2),d1		; cos(w)
	muls.w	#ms_x_radius*SHIRES_PIXEL_FACTOR*2,d1 ; x'=(cos(w)*rx)/2^15
	swap	d1
	add.w	#ms_x_center*SHIRES_PIXEL_FACTOR,d1 ; x' + x center
	addq.w	#msr_x_angle_speed,d2
	cmp.w	#sine_table_length2/2,d2 ; 180° ?
	ble.s	move_spaceship_right_skip
	move.w	#FALSE,msr_active(a3)
	rts
	CNOP 0,4
move_spaceship_right_skip
	move.w	d2,msr_x_angle(a3)
	move.w	#(display_window_hstart-ms_image_x_size)*SHIRES_PIXEL_FACTOR,d0 ; x
	add.w	d1,d0			; HSTOP: x centering
	MOVEF.W msl_spaceship_y_position,d1 ;VSTART
	moveq	#ms_image_y_size,d2
	add.w	d1,d2			; VSTOP
	lea	spr_ptrs_construction(pc),a2
	move.l	(a2)+,a0		; 1st sprite structure
	ADDF.W	spr0_extension2_entry,a0
	move.l	(a2),a1			; 2nd sprite structure
	ADDF.W	spr1_extension2_entry,a1
	SET_SPRITE_POSITION d0,d1,d2
	move.w	d1,(a0)			; SPRxPOS
	move.w	d2,spr_pixel_per_datafetch/8(a0) ; SPRxCTL
	move.w	d1,(a1)			; SPRxPOS
	or.b	#SPRCTLF_ATT,d2
	move.w	d2,spr_pixel_per_datafetch/8(a1) ; SPRxCTL
move_spaceship_right_quit
	rts


	CNOP 0,4
msr_copy_bitmaps
	lea	msr_image_data,a2
	bsr.s	ms_copy_image_data
	rts


; Input
; a2.l	image data
; Result
	CNOP 0,4
ms_copy_image_data
	movem.l d1/a0/a4-a6,-(a7)
	lea	spr_ptrs_construction(pc),a5
	move.l	(a5)+,a0		; 1st sprite structure
	ADDF.W	spr0_extension2_entry+((spr_pixel_per_datafetch/8)*2),a0 ; skip header
	move.l	(a5),a1			; 2nd sprite structure
	ADDF.W	spr1_extension2_entry+((spr_pixel_per_datafetch/8)*2),a1 ; skip header
	lea	spr_ptrs_display(pc),a5 ; Zeiger auf Sprites
	move.l	(a5)+,a4		; 1st sprite structure
	ADDF.W	spr0_extension2_entry+((spr_pixel_per_datafetch/8)*2),a4 ; skip header
	move.l	(a5),a5			; 2nd sprite structure
	ADDF.W	spr1_extension2_entry+((spr_pixel_per_datafetch/8)*2),a5 ; skip header
	moveq	#ms_image_y_size-1,d7
ms_copy_image_data_loop
	movem.l (a2)+,d0-d6/a6		; fetch 64 bits with 4 bitplanes
	move.l	d0,(a0)+		; bitplane 1 even sprite
	move.l	d1,(a0)+
	move.l	d2,(a0)+		; bitplane 2 even sprite
	move.l	d3,(a0)+
	move.l	d4,(a1)+		; bitplane 1 odd sprite
	move.l	d5,(a1)+
	move.l	d6,(a1)+		; bitplane 2 odd sprite
	move.l	a6,(a1)+

	move.l	d0,(a4)+		; bitplane 1 even sprite
	move.l	d1,(a4)+
	move.l	d2,(a4)+		; bitplane 2 even sprite
	move.l	d3,(a4)+
	move.l	d4,(a5)+		; bitplane 1 odd sprite
	move.l	d5,(a5)+
	move.l	d6,(a5)+		; bitplane 2 odd sprite
	move.l	a6,(a5)+
	dbf	d7,ms_copy_image_data_loop
	movem.l (a7)+,d1/a0/a4-a6
	rts


	CNOP 0,4
radius_fader_in
	tst.w	rfi_active(a3)
	bne.s	radius_fader_in_quit
	subq.w	#rfi_delay_speed,rfi_delay_counter(a3)
	bgt.s	radius_fader_in_quit
	move.w	#rfi_delay,rfi_delay_counter(a3)
	move.w	sb_variable_y_radius(a3),d0
	cmp.w	#rf_max_y_radius,d0
	blt.s	radius_fader_in_skip
	move.w	#FALSE,rfi_active(a3)
	rts
	CNOP 0,4
radius_fader_in_skip
	addq.w	#rfi_speed,d0		; increase y radius
	move.w	d0,sb_variable_y_radius(a3) 
radius_fader_in_quit
	rts


	CNOP 0,4
radius_fader_out
	tst.w	rfo_active(a3)
	bne.s	radius_fader_out_quit
	subq.w	#rfo_delay_speed,rfo_delay_counter(a3)
	bgt.s	radius_fader_out_quit
	move.w	#rfo_delay,rfo_delay_counter(a3)
	move.w	sb_variable_y_radius(a3),d0
	bgt.s	radius_fader_out_skip
	move.w	#FALSE,rfo_active(a3)
	rts
	CNOP 0,4
radius_fader_out_skip
	subq.w	#rfo_speed,d0		; decrease y radius
	move.w	d0,sb_variable_y_radius(a3) 
radius_fader_out_quit
	rts


	CNOP 0,4
image_fader_in
	movem.l a4-a6,-(a7)
	tst.w	ifi_rgb8_active(a3)
	bne.s	image_fader_in_quit
	move.w	ifi_rgb8_fader_angle(a3),d2
	move.w	d2,d0
	ADDF.W	ifi_rgb8_fader_angle_speed,d0
	cmp.w	#sine_table_length1/2,d0 ; 180° ?
	ble.s	image_fader_in_skip
	MOVEF.W sine_table_length1/2,d0
image_fader_in_skip
	move.w	d0,ifi_rgb8_fader_angle(a3) 
	MOVEF.W if_rgb8_colors_number*3,d6 ; RGB counter
	lea	sine_table(pc),a0	
	move.l	(a0,d2.w*4),d0		; sin(w)
	MULUF.L ifi_rgb8_fader_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
	swap	d0
	ADDF.W	ifi_rgb8_fader_center,d0
	lea	pf1_rgb8_color_table+(if_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a0 ; colors buffer
	lea	ifi_rgb8_color_table+(if_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a1 ; destination colors
	move.w	d0,a5			; increase/decrease blue
	swap	d0
	clr.w	d0
	move.l	d0,a2			; increase/decrease red
	lsr.l	#8,d0
	move.l	d0,a4			; increase/decrease green
	MOVEF.W if_rgb8_colors_number-1,d7
	bsr	if_rgb8_fader_loop
	move.w	d6,if_rgb8_colors_counter(a3) ; image-fader-in finished ?
	bne.s	image_fader_in_quit
	move.w	#FALSE,ifi_rgb8_active(a3)
image_fader_in_quit
	movem.l (a7)+,a4-a6
	rts


	CNOP 0,4
image_fader_out
	movem.l a4-a6,-(a7)
	tst.w	ifo_rgb8_active(a3)
	bne.s	image_fader_out_quit
	move.w	ifo_rgb8_fader_angle(a3),d2
	move.w	d2,d0
	ADDF.W	ifo_rgb8_fader_angle_speed,d0
	cmp.w	#sine_table_length1/2,d0 ; 180° ?
	ble.s	image_fader_out_skip
	MOVEF.W sine_table_length1/2,d0
image_fader_out_skip
	move.w	d0,ifo_rgb8_fader_angle(a3) 
	MOVEF.W if_rgb8_colors_number*3,d6 ; RGB counter
	lea	sine_table(pc),a0	
	move.l	(a0,d2.w*4),d0	; sin(w)
	MULUF.L ifo_rgb8_fader_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
	swap	d0
	ADDF.W	ifo_rgb8_fader_center,d0
	lea	pf1_rgb8_color_table+(if_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a0 ; colors buffer
	lea	ifo_rgb8_color_table+(if_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a1 ; destination colors
	move.w	d0,a5			; increase/decrease blue
	swap	d0
	clr.w	d0
	move.l	d0,a2			; increase/decrease red
	lsr.l	#8,d0
	move.l	d0,a4			; increase/decrease green
	MOVEF.W if_rgb8_colors_number-1,d7
	bsr.s	if_rgb8_fader_loop
	move.w	d6,if_rgb8_colors_counter(a3) ; image-fader-out finished ?
	bne.s	image_fader_out_quit
	move.w	#FALSE,ifo_rgb8_active(a3)
image_fader_out_quit
	movem.l (a7)+,a4-a6
	rts


	RGB8_COLOR_FADER if


	COPY_RGB8_COLORS_TO_COPPERLIST if,pf1,cl2,cl2_ext2_COLOR01_high1,cl2_ext2_COLOR01_low1,cl2_extension2_entry


	CNOP 0,4
sprite_fader_in
	movem.l a4-a6,-(a7)
	tst.w	sprfi_rgb8_active(a3)
	bne.s	sprite_fader_in_quit
	move.w	sprfi_rgb8_fader_angle(a3),d2
	move.w	d2,d0
	ADDF.W	sprfi_rgb8_fader_angle_speed,d0
	cmp.w	#sine_table_length1/2,d0 ; 180° ?
	ble.s	sprite_fader_in_skip
	MOVEF.W sine_table_length1/2,d0
sprite_fader_in_skip
	move.w	d0,sprfi_rgb8_fader_angle(a3) 
	MOVEF.W sprf_rgb8_colors_number*3,d6 ; RGB counter
	lea	sine_table(pc),a0	
	move.l	(a0,d2.w*4),d0		; sin(w)
	MULUF.L sprfi_rgb8_fader_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
	swap	d0
	ADDF.W	sprfi_rgb8_fader_center,d0
	lea	spr_rgb8_color_table+(sprf_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a0 ; colors buffer
	lea	sprfi_rgb8_color_table+(sprf_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a1 ; destination colors
	move.w	d0,a5			; increase/decrease blue
	swap	d0
	clr.w	d0
	move.l	d0,a2			; increase/decrease red
	lsr.l	#8,d0
	move.l	d0,a4			; increase/decrease green
	MOVEF.W sprf_rgb8_colors_number-1,d7
	bsr	if_rgb8_fader_loop
	move.w	d6,sprf_rgb8_colors_counter(a3) ; sprite-fader-in finished ?
	bne.s	sprite_fader_in_quit
	move.w	#FALSE,sprfi_rgb8_active(a3)
sprite_fader_in_quit
	movem.l (a7)+,a4-a6
	rts


	CNOP 0,4
sprite_fader_out
	movem.l a4-a6,-(a7)
	tst.w	sprfo_rgb8_active(a3)
	bne.s	sprite_fader_out_quit
	move.w	sprfo_rgb8_fader_angle(a3),d2
	move.w	d2,d0
	ADDF.W	sprfo_rgb8_fader_angle_speed,d0
	cmp.w	#sine_table_length1/2,d0 ; 180° ?
	ble.s	sprite_fader_out_skip
	MOVEF.W sine_table_length1/2,d0
sprite_fader_out_skip
	move.w	d0,sprfo_rgb8_fader_angle(a3) 
	MOVEF.W sprf_rgb8_colors_number*3,d6 ; RGB counter
	lea	sine_table(pc),a0	
	move.l	(a0,d2.w*4),d0		; sin(w)
	MULUF.L sprfo_rgb8_fader_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
	swap	d0
	ADDF.W	sprfo_rgb8_fader_center,d0
	lea	spr_rgb8_color_table+(sprf_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a0 ; colors buffer
	lea	sprfo_rgb8_color_table+(sprf_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a1 ; destination colors
	move.w	d0,a5			; increase/decrease blue
	swap	d0
	clr.w	d0
	move.l	d0,a2			; increase/decrease red
	lsr.l	#8,d0
	move.l	d0,a4			; increase/decrease green
	MOVEF.W sprf_rgb8_colors_number-1,d7
	bsr	if_rgb8_fader_loop
	move.w	d6,sprf_rgb8_colors_counter(a3) ; sprite-fader-out finished ?
	bne.s	sprite_fader_out_quit
	move.w	#FALSE,sprfo_rgb8_active(a3)
sprite_fader_out_quit
	movem.l (a7)+,a4-a6
	rts


	COPY_RGB8_COLORS_TO_COPPERLIST sprf,spr,cl1,cl1_COLOR17_high1,cl1_COLOR17_low1


	CNOP 0,4
bar_fader_in
	movem.l a4-a6,-(a7)
	tst.w	bfi_rgb8_active(a3)
	bne.s	bar_fader_in_quit
	move.w	bfi_rgb8_fader_angle(a3),d2
	move.w	d2,d0
	ADDF.W	bfi_rgb8_fader_angle_speed,d0
	cmp.w	#sine_table_length1/2,d0 ; 180° ?
	ble.s	bar_fader_in_skip
	MOVEF.W sine_table_length1/2,d0
bar_fader_in_skip
	move.w	d0,bfi_rgb8_fader_angle(a3) 
	MOVEF.W bf_rgb8_colors_number*3,d6 ; RGB counter
	lea	sine_table(pc),a0	
	move.l	(a0,d2.w*4),d0		; sin(w)
	MULUF.L bfi_rgb8_fader_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
	swap	d0
	ADDF.W	bfi_rgb8_fader_center,d0
	lea	bf_rgb8_color_cache+(bf_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a0 ; colors buffer
	lea	bfi_rgb8_color_table+(bf_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a1 ; destination colors
	move.w	d0,a5		`	; increase/decrease blue
	swap	d0
	clr.w	d0
	move.l	d0,a2			; increase/decrease red
	lsr.l	#8,d0
	move.l	d0,a4			; increase/decrease green
	MOVEF.W bf_rgb8_colors_number-1,d7
	bsr	if_rgb8_fader_loop
	move.w	d6,bf_rgb8_colors_counter(a3) ; bar-fader-in finished ?
	bne.s	bar_fader_in_quit
	move.w	#FALSE,bfi_rgb8_active(a3)
bar_fader_in_quit
	movem.l (a7)+,a4-a6
	rts


	CNOP 0,4
bar_fader_out
	movem.l a4-a6,-(a7)
	tst.w	bfo_rgb8_active(a3)
	bne.s	bar_fader_out_quit
	move.w	bfo_rgb8_fader_angle(a3),d2
	move.w	d2,d0
	ADDF.W	bfo_rgb8_fader_angle_speed,d0
	cmp.w	#sine_table_length1/2,d0 ; 180° ?
	ble.s	bar_fader_out_skip
	MOVEF.W sine_table_length1/2,d0
bar_fader_out_skip
	move.w	d0,bfo_rgb8_fader_angle(a3) 
	MOVEF.W bf_rgb8_colors_number*3,d6 ; RGB counter
	lea	sine_table(pc),a0	
	move.l	(a0,d2.w*4),d0		; sin(w)
	MULUF.L bfo_rgb8_fader_radius*2,d0,d1 ; y'=(yr*sin(w))/2^15
	swap	d0
	ADDF.W	bfo_rgb8_fader_center,d0
	lea	bf_rgb8_color_cache+(bf_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a0 ; colors buffer
	lea	bfo_rgb8_color_table+(bf_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a1 ; destination colors
	move.w	d0,a5			; increase/decrease blue
	swap	d0
	clr.w	d0
	move.l	d0,a2			; increase/decrease red
	lsr.l	#8,d0
	move.l	d0,a4			; increase/decrease green
	MOVEF.W bf_rgb8_colors_number-1,d7
	bsr	if_rgb8_fader_loop
	move.w	d6,bf_rgb8_colors_counter(a3) ; bar-fader-out finished ?
	bne.s	bar_fader_out_quit
	move.w	#FALSE,bfo_rgb8_active(a3)
bar_fader_out_quit
	movem.l (a7)+,a4-a6
	rts


	CNOP 0,4
bf_rgb8_convert_colors
	tst.w	bf_rgb8_convert_colors_active(a3)
	bne.s	bf_rgb8_convert_colors_quit
	move.w	#RB_NIBBLES_MASK,d3
	lea	bf_rgb8_color_cache(pc),a0 ; source: colors buffer
	lea	scs_bar_color_table+(bf_rgb8_color_table_offset*LONGWORD_SIZE)(pc),a1 ; destination1: bar color table
	lea	scs_bar_color_table+(bf_rgb8_color_table_offset*LONGWORD_SIZE)+(bf_rgb8_colors_number*LONGWORD_SIZE)(pc),a2 ; destination2: end of bar color table
	MOVEF.W (bf_rgb8_colors_number/2)-1,d7
bf_rgb8_convert_colors_loop
	move.l	(a0)+,d0		; RGB8
	move.l	d0,d2		
	RGB8_TO_RGB4_HIGH d0,d1,d3
	move.w	d0,(a1)+		; color high
	RGB8_TO_RGB4_LOW d2,d1,d3
	move.w	d2,(a1)+		; color low
	move.w	d2,-(a2)		; color low
	move.w	d0,-(a2)		; color high
	dbf	d7,bf_rgb8_convert_colors_loop
	tst.w	bf_rgb8_colors_counter(a3) ; converting finished ?
	bne.s	bf_rgb8_convert_colors_quit
	move.w	#FALSE,bf_rgb8_convert_colors_active(a3)
bf_rgb8_convert_colors_quit
	rts


	CNOP 0,4
control_counters
	move.w	scs_text_delay_counter(a3),d0
	bmi.s	control_counters_quit
	subq.w	#1,d0
	bpl.s	control_counters_skip
	clr.w	scs_text_move_active(a3)
	moveq	#FALSE,d0		; stop counter
control_counters_skip
	move.w	d0,scs_text_delay_counter(a3) 
control_counters_quit
	rts


	CNOP 0,4
mouse_handler
	btst	#CIAB_GAMEPORT0,CIAPRA(a4) ; LMB pressed ?
	beq.s	mh_exit_demo
	btst	#POTINPB_DATLY,POTINP-DMACONR(a6) ; RMB pressed ?
	beq.s	mh_start_spaceship
	rts
	CNOP 0,4
mh_exit_demo
	moveq	#FALSE,d1
	move.w	d1,pt_effects_handler_active(a3)
	moveq	#TRUE,d0
	move.w	d1,mh_start_spaceship_active(a3)
	tst.w	scs_enabled(a3)
	bne.s	mh_exit_demo_skip1
	move.w	#scs_stop_text-scs_text,scs_text_table_start(a3) ; end scrolltext
	move.w	d0,exit_active(a3)	; intro should end after text stop
	bra.s	mh_start_spaceship_quit
	CNOP 0,4
mh_exit_demo_skip1
	move.w	d0,pt_music_fader_active(a3)
	move.w	#if_rgb8_colors_number*3,if_rgb8_colors_counter(a3)
	move.w	d0,ifo_rgb8_active(a3)
	move.w	d0,if_rgb8_copy_colors_active(a3)
	tst.w	ifi_rgb8_active(a3)
	bne.s	mh_exit_demo_skip2
	move.w	d1,ifi_rgb8_active(a3)
mh_exit_demo_skip2
	move.w	#sprf_rgb8_colors_number*3,sprf_rgb8_colors_counter(a3)
	move.w	d0,sprfo_rgb8_active(a3)
	move.w	d0,sprf_rgb8_copy_colors_active(a3)
	tst.w	sprfi_rgb8_active(a3)
	bne.s	mh_exit_demo_skip3
	move.w	d1,sprfi_rgb8_active(a3)
mh_exit_demo_skip3
	move.w	#bf_rgb8_colors_number*3,bf_rgb8_colors_counter(a3)
	move.w	d0,bf_rgb8_convert_colors_active(a3)
	move.w	d0,bfo_rgb8_active(a3)
	tst.w	bfi_rgb8_active(a3)
	bne.s	mh_exit_demo_skip4
	move.w	d1,bfi_rgb8_active(a3)
mh_exit_demo_skip4
	bra.s	mh_start_spaceship_quit
	CNOP 0,4
mh_start_spaceship
	tst.w	mh_start_spaceship_active(a3)
	bne.s	mh_start_spaceship_quit
	tst.w	msl_active(a3)
	beq.s	mh_start_spaceship_quit
	tst.w	msr_active(a3)
	beq.s	mh_start_spaceship_quit
	bsr	msl_copy_bitmaps
	clr.w	msl_active(a3)		; start spaceship to left
	move.w	#sine_table_length2/4,msl_x_angle(a3) ; 90°
mh_start_spaceship_quit
	rts


	INCLUDE "int-autovectors-handlers.i"

	IFEQ pt_ciatiming_enabled
		CNOP 0,4
ciab_ta_int_server
	ENDC

	IFNE pt_ciatiming_enabled
		CNOP 0,4
VERTB_int_server
	ENDC


; PT-Replay
	IFEQ pt_music_fader_enabled
		bsr.s	pt_music_fader
		bra.s	pt_PlayMusic

		PT_FADE_OUT_VOLUME stop_fx_active

		CNOP 0,4
	ENDC

	IFD PROTRACKER_VERSION_2 
		PT2_REPLAY pt_effects_handler
	ENDC
	IFD PROTRACKER_VERSION_3
		PT3_REPLAY pt_effects_handler
	ENDC

	CNOP 0,4
pt_effects_handler
	tst.w	pt_effects_handler_active(a3)
	bne.s	pt_effects_handler_quit
	move.b	n_cmdlo(a2),d0
	beq.s	pt_start_intro
	cmp.b	#$10,d0
	beq.s	pt_increase_x_radius_angle_step
	cmp.b	#$20,d0
	beq.s	pt_start_get_z_planes_step
	cmp.b	#$30,d0
	beq.s	pt_start_scrolltext
	cmp.b	#$40,d0
	beq.s	pt_enable_spaceship
pt_effects_handler_quit
	rts
	CNOP 0,4
pt_start_intro
	moveq	#TRUE,d0
	move.w	d0,ifi_rgb8_active(a3)
	move.w	#if_rgb8_colors_number*3,if_rgb8_colors_counter(a3)
	move.w	d0,if_rgb8_copy_colors_active(a3)

	move.w	d0,sprfi_rgb8_active(a3)
	move.w	#sprf_rgb8_colors_number*3,sprf_rgb8_colors_counter(a3)
	move.w	d0,sprf_rgb8_copy_colors_active(a3)

	move.w	d0,bfi_rgb8_active(a3)
	move.w	#bf_rgb8_colors_number*3,bf_rgb8_colors_counter(a3)
	move.w	d0,bf_rgb8_convert_colors_active(a3)
	rts
	CNOP 0,4
pt_start_get_z_planes_step
	clr.w	hcs_get_horiz_step_active(a3)
	rts
	CNOP 0,4
pt_increase_x_radius_angle_step
	addq.w	#1,hsi_x_radius_angle_step(a3)
	rts
	CNOP 0,4
pt_start_scrolltext
	clr.w	scs_enabled(a3)
	clr.w	scs_text_table_start(a3) ; text start
	rts
	CNOP 0,4
pt_enable_spaceship
	clr.w	mh_start_spaceship_active(a3)
	rts

	CNOP 0,4
ciab_tb_int_server
	PT_TIMER_INTERRUPT_SERVER

	CNOP 0,4
EXTER_int_server
	rts

	CNOP 0,4
nmi_int_server
	rts


	INCLUDE "help-routines.i"


	INCLUDE "sys-structures.i"


	CNOP 0,4
pf1_rgb8_color_table
	DC.L color00_bits


	CNOP 0,4
vp1_pf1_rgb8_color_table
	REPT vp1_pf1_colors_number
		DC.L color00_bits
	ENDR


	CNOP 0,4
vp2_pf1_rgb8_color_table
	DC.L color00_bits


	CNOP 0,4
vp2_pf2_rgb8_color_table
	DC.L color00_bits


	CNOP 0,4
spr_rgb8_color_table
	REPT spr_colors_number
		DC.L color00_bits
	ENDR


	CNOP 0,4
vp2_spr_rgb8_color_table
	INCLUDE "CoolCorkscrew:colortables/64x32x16-Spaceship.ct"


	CNOP 0,4
spr_ptrs_construction
	DS.L spr_number


	CNOP 0,4
spr_ptrs_display
	DS.L spr_number


	CNOP 0,4
sine_table
	INCLUDE "sine-table-256x32.i"


	CNOP 0,2
sine_table_512
	INCLUDE "sine-table-512x16.i"


; PT-Replay 
	INCLUDE "music-tracker/pt-invert-table.i"

	INCLUDE "music-tracker/pt-vibrato-tremolo-table.i"

	IFD PROTRACKER_VERSION_2 
		INCLUDE "music-tracker/pt2-period-table.i"
	ENDC
	IFD PROTRACKER_VERSION_3
		INCLUDE "music-tracker/pt3-period-table.i"
	ENDC

	INCLUDE "music-tracker/pt-temp-channel-data-tables.i"

	INCLUDE "music-tracker/pt-sample-starts-table.i"

	INCLUDE "music-tracker/pt-finetune-starts-table.i"


; Horiz-Scaling-Image
hsi_shift_table
	DS.B hsi_shift_values_number

	CNOP 0,2
hsi_radius_table
	DS.W hsi_lines_number

	CNOP 0,2
hsi_bplcon1_table
	DS.W cl2_display_width*hsi_lines_number
	DC.W vp1_bplcon1_bits


; Horiz-Characterscrolling
	CNOP 0,2
hcs_objects_x_coords
	DS.W hcs_objects_number


; Single-Corkscrew-Scroll
	CNOP 0,4
scs_color_gradient_front
	INCLUDE "CoolCorkscrew:colortables/2x32-Colorgradient-Blue.hlct"

	CNOP 0,4
scs_color_gradient_back
	INCLUDE "CoolCorkscrew:colortables/2x32-Colorgradient-Orchid.hlct"

	CNOP 0,4
scs_color_gradient_outline
	INCLUDE "CoolCorkscrew:colortables/2x32-Colorgradient-Grey.hlct"

	IFEQ scs_center_bar
		CNOP 0,4
scs_bar_color_table
		REPT sb_bar_height
			DC.L color00_bits
		ENDR
	ENDC

scs_ascii
	DC.B "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.!?-'():\/# "
scs_ascii_end
	EVEN

	CNOP 0,2
scs_characters_offsets
	DS.W scs_ascii_end-scs_ascii
	
	IFEQ scs_pipe_effect
		CNOP 0,2
scs_pipe_shift_x_table
		DS.W scs_roller_y_radius*2
	ENDC


; Sine-Bars 3.6 
	CNOP 0,4
sb36_yz_coords
	DS.W sb36_bars_number*2


; Image-Fader 
	CNOP 0,4
ifi_rgb8_color_table
	INCLUDE "CoolCorkscrew:colortables/256x30x16-Resistance.ct"

	CNOP 0,4
ifo_rgb8_color_table
	REPT vp1_pf1_colors_number
		DC.L color00_bits
	ENDR


; Sprite-Fader 
	CNOP 0,4
sprfi_rgb8_color_table
	INCLUDE "CoolCorkscrew:colortables/3x16x15x16-RSE.ct"

	CNOP 0,4
sprfo_rgb8_color_table
	REPT spr_colors_number
		DC.L color00_bits
	ENDR


; Bar-Fader 
	CNOP 0,4
bfi_rgb8_color_table
	INCLUDE "CoolCorkscrew:colortables/5-Colorgradient-Orchid.ct"

	CNOP 0,4
bfo_rgb8_color_table
	REPT sb_bar_height
		DC.L color00_bits
	ENDR

	CNOP 0,4
bf_rgb8_color_cache
	REPT sb_bar_height
		DC.L color00_bits
	ENDR


	INCLUDE "sys-variables.i"


	INCLUDE "sys-names.i"


	INCLUDE "error-texts.i"


; Single-Corkscrew-Scroll 
scs_text
	DC.B ASCII_CTRL_C,"RESISTANCE",ASCII_CTRL_P," PRESENTS A NEW INTRO CALLED          COOL¹   ",ASCII_CTRL_P,"          CORKSCREW ",ASCII_CTRL_P,ASCII_CTRL_F,"          "

	DC.B "THIS IS OUR CONTRIBUTION TO ",ASCII_CTRL_A,"DEADLINE 2024           "

	DC.B "PRESS RMB TO START ",ASCII_CTRL_A,"SPACESHIP               "

	DC.B ASCII_CTRL_C,"²GREETINGS ",ASCII_CTRL_A,"FLY TO           ",ASCII_CTRL_N
	DC.B "# DESIRE #         "
	DC.B "# EPHIDRENA #         "
	DC.B "# FOCUS DESIGN #         "
	DC.B "# GHOSTOWN #         "
	DC.B "# NAH-KOLOR #         "
	DC.B "# PLANET JAZZ #         "
	DC.B "# SOFTWARE FAILURE #         "
	DC.B "# TEK #         "
	DC.B "# WANTED TEAM #",ASCII_CTRL_F,"           "

	DC.B ASCII_CTRL_C,"¹THE CREDITS          "
	DC.B "CODING AND MUSIC          "
	DC.B "DISSIDENT ",ASCII_CTRL_A,ASCII_CTRL_P,"          "
	DC.B "GRAPHICS          "
	DC.B "  GRASS   ",ASCII_CTRL_A,ASCII_CTRL_P,ASCII_CTRL_F,"         "
scs_stop_text
	REPT ((scs_text_characters_number)/(scs_origin_char_x_size/scs_text_char_x_size))-2
		DC.B " "
	ENDR
	DC.B ASCII_CTRL_S," "
	EVEN


	DC.B "$VER: "
	DC.B "RSE-CoolCorkscrew "
	DC.B "1.4 "
	DC.B "(31.8.24)",0
	EVEN


; Audio data

; PT-Replay 
	IFEQ pt_split_module_enabled
pt_auddata			SECTION pt_audio,DATA
		INCBIN "CoolCorkscrew:modules/mod.RetroDisco(remix).song"
pt_audsmps			SECTION pt_audio2,DATA_C
		INCBIN "CoolCorkscrew:modules/mod.RetroDisco(remix).smps"
	ELSE
pt_auddata			SECTION pt_audio,DATA_C
		INCBIN "CoolCorkscrew:modules/mod.RetroDisco(remix)"
	ENDC


; Gfx data

; Background-Image 
bg_image_data			SECTION bg_gfx,DATA
	INCBIN "CoolCorkscrew:graphics/256x30x16-Resistance.rawblit"

; Horiz-Charactersrolling 
hcs_image_data			SECTION hcs_gfx,DATA
	INCBIN "CoolCorkscrew:graphics/3x16x15x16-RSE.rawblit"

; Single-Corkscrew-Scroll 
scs_image_data			SECTION scs_gfx,DATA_C
	INCBIN "CoolCorkscrew:fonts/32x32x4-Font.rawblit"

; Spaceship-Image 
msl_image_data			SECTION msl_gfx,DATA
	INCBIN "CoolCorkscrew:graphics/64x32x16-Spaceship-Left.rawblit"

msr_image_data			SECTION msr_gfx,DATA
	INCBIN "CoolCorkscrew:graphics/64x32x16-Spaceship-Right.rawblit"

	END
