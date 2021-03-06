###############
# F3KDB_3 and it sisters v1.3


function F3KDB_3(clip clip, int "range", int "Y", int "Cb", int "Cr", \
		int "grainY", int "grainC", int "sample_mode", int "seed", \
		bool "blur_first", bool "dynamic_grain", int "opt", bool "mt", \
		int "dither_algo", bool "keep_tv_range", int "input_mode", \
		int "input_depth", int "output_mode", int "output_depth", \
		int "random_algo_ref", int "random_algo_grain", \
		float "random_param_ref", float "random_param_grain", bool "chroma", int "pass", bool "lastpassgrain", bool "masking", float "mask_thr", int "mask_radius", bool "lastpassmask") {

		try { 
sample_mode = default (sample_mode, 4)
pass = default (pass, sample_mode==4 ? 2 : 1)
isgrYd = defined(grainY)
lpgra  = default (lastpassgrain, !isgrYd && pass > 1)
lpmsk  = default (lastpassmask, lpgra && pass > 1)
grainY = isgrYd && !lpgra ? grainY : pass > 1 ? 0 : pass < 2 && lpgra ? undefined : 0
chromad = defined(chroma)
chroma      = default (chroma, true)
cb = default (cb, chroma ? undefined : 0)
cr = default (cr, chroma ? undefined : 0)
grainC = default (grainC, chromad && chroma ? 64 : chroma ? grainY : 0)
sisphbd   = AvsPlusVersionNumber > 2294
sischbd  = sisphbd ? clip.BitsPerComponent() > 8 : false
input_depth = defined(input_depth) ? input_depth : defined(input_mode) ? input_mode>0 ? 16 : 8 : 8
output_depth = defined(output_depth) ? output_depth : sischbd ? undefined : defined(output_mode) ? output_mode>0 ? 16 : 8 : 8
input_mode  = default (input_mode, input_depth==8 || sischbd ? 0 : 1)
output_mode = default (output_mode, sischbd ? 0 : output_depth==8 ? 0 : 1)
masking      = default (masking, true)
sisyuy2 = clip.isyuy2()
pclip   = sisyuy2 ? clip.ConvertToYV16() : clip
pclip   = input_mode==1 ? pclip.ConvertFromStacked(input_depth) : input_mode==2 ? pclip.ConvertFromDoubleWidth(input_depth) : pclip

Assert(!(input_mode>0 && sischbd), "F3KDB_3: lsb/interleaved hack is not Compatible with HBD")
Assert(!(output_mode>0 && sischbd), "F3KDB_3: lsb/interleaved hack is not Compatible with HBD")
Assert(isYUV(clip), "F3KDB_3: YUV only")

pclip.neo_F3KDB(range, Y, Cb, Cr, \
		grainY, grainC, sample_mode, seed, \
		blur_first, dynamic_grain, opt, mt, \
		dither_algo, keep_tv_range, \
		output_depth, \
		random_algo_ref, random_algo_grain, \
		random_param_ref, random_param_grain)

masking && (lpmsk ? pass < 2 : true) ? mt_merge(last,pclip,pclip.F3KDB_3_masking(mask_thr, mask_radius), u=chroma ? 3 : 2, v=chroma ? 3 : 2, luma=chroma) : last

output_mode==1 ? pclip.convertbits(16,false).ConvertToStacked() : output_mode==2 ? pclip.convertbits(16,false).ConvertToDoubleWidth() : last

        pass > 1 ? last.F3KDB_3(range, Y, Cb, Cr, \
		grainY, grainC, sample_mode, seed, \
		blur_first, dynamic_grain, opt, mt, \
		dither_algo, keep_tv_range, input_mode, \
		input_depth, output_mode, output_depth, \
		random_algo_ref, random_algo_grain, \
		random_param_ref, random_param_grain, chroma, pass - 1, lpgra, masking, mask_thr, mask_radius) : last

sisyuy2 ? ConvertToYUY2() : last

} catch(error_msg) { clip.L_F3KDB_3(range, Y, Cb, Cr, \
		grainY, grainC, sample_mode, seed, \
		blur_first, dynamic_grain, opt, mt, \
		dither_algo, keep_tv_range, input_mode, \
		input_depth, output_mode, output_depth, \
		random_algo_ref, random_algo_grain, \
		random_param_ref, random_param_grain, chroma, pass, lastpassgrain, masking, mask_thr, mask_radius, lastpassmask)  }
		
}


function L_F3KDB_3(clip clip, int "range", int "Y", int "Cb", int "Cr", \
		int "grainY", int "grainC", int "sample_mode", int "seed", \
		bool "blur_first", bool "dynamic_grain", int "opt", bool "mt", \
		int "dither_algo", bool "keep_tv_range", int "input_mode", \
		int "input_depth", int "output_mode", int "output_depth", \
		int "random_algo_ref", int "random_algo_grain", \
		float "random_param_ref", float "random_param_grain", bool "chroma", int "pass", bool "lastpassgrain", bool "masking", float "mask_thr", int "mask_radius", bool "lastpassmask") {
sisavs26     = !(VersionNumber() < 2.60)
sample_mode = default (sample_mode, 4)
pass = default (pass, sample_mode==4 ? 2 : 1)
isgrYd = defined(grainY)
lpgra  = default (lastpassgrain, !isgrYd && pass > 1)
lpmsk  = default (lastpassmask, lpgra && pass > 1)
grainY = isgrYd && !lpgra ? grainY : pass > 1 ? 0 : pass < 2 && lpgra ? undefined : 0
chromad = defined(chroma)
chroma      = default (chroma, true)
cb = default (cb, chroma ? undefined : 0)
cr = default (cr, chroma ? undefined : 0)
grainC = default (grainC, chromad && chroma ? 64 : chroma ? grainY : 0)
sisphbd   = AvsPlusVersionNumber > 2294
sischbd  = sisphbd ? clip.BitsPerComponent() > 8 : false
input_mode  = default (input_mode, 0)
output_mode = default (output_mode, sischbd ? 3 : input_mode)
sm4lsb = output_mode != 0 && output_mode != 3 && sample_mode == 4
sm4i16 = sm4lsb && output_mode == 2
output_mode = sm4i16 ? 1 : output_mode
masking      = default (masking, true)
Assert(masking && output_mode==2 ? sample_mode==4 : true, "L_F3KDB_3: when using output_mode=2 masking only work with sample_mode=4")
sisyuy2 = clip.isyuy2()
pclip   = sisyuy2 && sisavs26 ? clip.ConvertToYV16() : clip

sample_mode != 4 ? Eval("""
i_mode  = sischbd ? 2 : input_mode
o_mode = output_mode == 3 ? 2 : output_mode
i_depth   = sischbd ? clip.BitsPerComponent() : defined(input_depth) ? input_depth : 8

Assert(!(sischbd && (input_mode>0)), "L_F3KDB_3: lsb/interleaved hack is not Compatible with HBD")
Assert(isYUV(clip), "L_F3KDB_3: YUV only")
noSquarechr = sisphbd ? (is422(clip) || isyv411(clip)) : sisavs26 ? (isyv16(clip) || isyv411(clip)) : false
Assert(!(sample_mode==3 && chroma && (sisyuy2 || noSquarechr)), "L_F3KDB_3: Square chroma only for sample_mode > 2")

o_depth     = defined(output_depth) ? output_depth : i_depth
smode       = sample_mode > 2 ? 1 : sample_mode

pclip2   = sample_mode == 3 ? pclip.sTryFTurnLeft(chroma,input_mode==2 ? 16 : input_mode==1 ? 88 : 8,mt) : pclip

i16clip = sischbd ? i_depth != 8 ? pclip2.convertbits(16,false).ConvertToDoubleWidth() : pclip2.ConvertToDoubleWidth() : pclip2

F3KDB_clip = i16clip.F3KDB(range, Y, Cb, Cr, \
		grainY, grainC, smode, seed, \
		blur_first, dynamic_grain, opt, mt, \
		dither_algo, keep_tv_range, i_mode, \
		i_depth, o_mode, o_depth, \
		random_algo_ref, random_algo_grain, \
		random_param_ref, random_param_grain)

F3KDB_clip = output_mode == 3 && sischbd ? F3KDB_clip.ConvertFromDoubleWidth(o_depth) : F3KDB_clip

sample_mode == 3 ? F3KDB_clip.sTryFTurnRight(chroma,output_mode==2 ? 16 : output_mode==1 ? 88 : 8,mt) : F3KDB_clip

""") : sm4lsb ? Dither_merge16(pclip.L_F3KDB_3(range, Y, Cb, Cr, \
		grainY, grainC, 1, seed, \
		blur_first, dynamic_grain, opt, mt, \
		dither_algo, keep_tv_range, input_mode, \
		input_depth, 1, output_depth, \
		random_algo_ref, random_algo_grain, \
		random_param_ref, random_param_grain, chroma, 1, pass == 1 ? lpgra : false, false),pclip.L_F3KDB_3(range, Y, Cb, Cr, \
		grainY, grainC, 3, seed, \
		blur_first, dynamic_grain, opt, mt, \
		dither_algo, keep_tv_range, input_mode, \
		input_depth, 1, output_depth, \
		random_algo_ref, random_algo_grain, \
		random_param_ref, random_param_grain, chroma, 1, pass == 1 ? lpgra : false, false),BlankClip(input_mode != 1 ? pclip.Bitdepth(from=input_mode == 2 ? 16 : 8, to=88) : pclip,color_yuv=color_gray).BitdepthMsb(bitdepth=88).Bitdepth(from=8, to=88),luma=chroma) \
		: Merge(pclip.L_F3KDB_3(range, Y, Cb, Cr, \
		grainY, grainC, 1, seed, \
		blur_first, dynamic_grain, opt, mt, \
		dither_algo, keep_tv_range, input_mode, \
		input_depth, output_mode, output_depth, \
		random_algo_ref, random_algo_grain, \
		random_param_ref, random_param_grain, chroma, 1, pass == 1 ? lpgra : false, false),pclip.L_F3KDB_3(range, Y, Cb, Cr, \
		grainY, grainC, 3, seed, \
		blur_first, dynamic_grain, opt, mt, \
		dither_algo, keep_tv_range, input_mode, \
		input_depth, output_mode, output_depth, \
		random_algo_ref, random_algo_grain, \
		random_param_ref, random_param_grain, chroma, 1, pass == 1 ? lpgra : false, false))

masking && (lpmsk ? pass < 2 : true) ? sm4i16 || output_mode == 1 ? Dither_merge16_8(last,input_mode!=1 ? pclip.Bitdepth(from=input_mode==2 ? 16 : 8, to=88) : pclip,input_mode!=0 ? pclip.Bitdepth(from=input_mode==2 ? 16 : 88, to=8).F3KDB_3_masking(mask_thr, mask_radius) : pclip.F3KDB_3_masking(mask_thr, mask_radius), luma=chroma) : mt_merge(last,pclip,pclip.F3KDB_3_masking(mask_thr, mask_radius), u=chroma ? 3 : 2, v=chroma ? 3 : 2, luma=chroma) : last
output_mode = sm4i16 ? 2 : output_mode
sm4i16 ? Bitdepth(from=88, to=16) : last

        pass > 1 ? last.L_F3KDB_3(range, Y, Cb, Cr, \
		grainY, grainC, sample_mode, seed, \
		blur_first, dynamic_grain, opt, mt, \
		dither_algo, keep_tv_range, input_mode, \
		input_depth, output_mode, output_depth, \
		random_algo_ref, random_algo_grain, \
		random_param_ref, random_param_grain, chroma, pass - 1, lpgra, masking, mask_thr, mask_radius) : last

yuy26 ? ConvertToYUY2() : last

}


function F3KDB_3_masking(clip c, float "mask_thr", int "mask_radius")
{
sisavs26     = !(VersionNumber() < 2.60)
mthr = default(mask_thr, 2)
mrad = default(mask_radius, 2)
Assert(mrad > 0, "F3KDB_3_masking: mask_radius must be more than 0")

thr_lo = string(max(mthr * 0.75, 1) - 0.0001)
thr_hi = string(max(mthr,         1) + 0.0001)

c
mrad > 1 ? sisavs26 ? mt_lutxy (mt_expand_multi (sw=mrad, sh=mrad, mode="ellipse"), mt_inpand_multi (sw=mrad, sh=mrad, mode="ellipse"), "x y -",clamp_float=true, use_expr=1) : mt_lutxy (mt_expand_multi (sw=mrad, sh=mrad, mode="ellipse"), mt_inpand_multi (sw=mrad, sh=mrad, mode="ellipse"), "x y -") : mt_edge (mode="min/max", thY1=0, thY2=255)
sisavs26 ? mt_lut (expr="x "+thr_lo+" scalef - "+thr_hi+" scalef "+thr_lo+" scalef - / 0 1 clip range_max *", use_expr=2) : mt_lut (expr="x "+thr_lo+" - "+thr_hi+" "+thr_lo+" - / 0 1 clip 255 *")
removegrain (22, -1)
mrad > 1 ? removegrain (11, -1) : last
mrad > 2 ? removegrain (20, -1) : last
}


# F3KDB_3_adg F3KDB_3 with adaptive grain

function F3KDB_3_adg(clip clip, int "range", int "Y", int "Cb", int "Cr", int "seed", \
		bool "blur_first", bool "dynamic_grain", int "opt", bool "mt", \
		int "dither_algo", bool "keep_tv_range", \
		int "random_algo_ref", int "random_algo_grain", \
		float "random_param_ref", float "random_param_grain", bool "chroma", int "pass", bool "masking", float "mask_thr", int "mask_radius", float "gf", float "gmin", float "gmax") {
pass = default (pass, 2)
masking = default (masking, true)
gf = default (gf, 512)
gmin = default (gmin, 12)
gmax = default (gmax, 100)
Assert(clip.BitsPerComponent() == 16, "F3KDB_3_adg: only work with avs+ HBD 16 bit")
pass != 1 ? clip.F3KDB_3(range, Y, Cb, Cr, 0, 0, 4, seed, \
		blur_first, dynamic_grain, opt, mt, \
		dither_algo, keep_tv_range, 0, \
		16, 3, 16, \
		random_algo_ref, random_algo_grain, \
		random_param_ref, random_param_grain, chroma, pass - 1, false, false, mask_thr, mask_radius) : clip
        pass > 1 ? last.F3KDB_3_adg(range, Y, Cb, Cr, seed, \
		blur_first, dynamic_grain, opt, mt, \
		dither_algo, keep_tv_range, \
		random_algo_ref, random_algo_grain, \
		random_param_ref, random_param_grain, chroma, pass - 1, masking, mask_thr, mask_radius, gf, gmin, gmax) : last
pass == 1 ? last.gScriptClip("""
last.F3KDB_3(range, Y, Cb, Cr, \
		round(max(min((65535-AverageLuma)/gf,gmax),gmin)), 0, 4, seed, \
		blur_first, dynamic_grain, opt, mt, \
		dither_algo, keep_tv_range, 0, \
		16, 3, 16, \
		random_algo_ref, random_algo_grain, \
		random_param_ref, random_param_grain, chroma, 1, false, masking, mask_thr, mask_radius)
""",args="range, Y, Cb, Cr, seed, blur_first, dynamic_grain, opt, mt, dither_algo, keep_tv_range, random_algo_ref, random_algo_grain, random_param_ref, random_param_grain, chroma, masking, mask_thr, mask_radius, gf, gmin, gmax") : last
}