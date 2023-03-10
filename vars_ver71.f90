module state_space 
real:: edu(6) = (/6, 11, 12, 14, 16, 18/) ! education 
real:: mdur(3) = (/0, 1, 4/) ! marriage duration 0 - 2
real:: wexp(5) = (/0., 2., 4., 8., 15./) ! human capital 
real:: knum(4) = (/0, 2, 4, 7/) ! number of kids 0 - 3
real:: kage(4) = (/0, 4, 5, 18/)! age of kids 0 - 4
real:: emax(6,3,5,4,4), emax_all(13,5,31,8,19), emax1, emax0
real:: edul, eduh, wexpl, wexph, kagel, kageh, mdurl, mdurh, z_edu, z_wexp, z_kage, z_mdur, sum_weight, knuml, knumh, z_knum
real:: v_grid(2,2,2,2,2), aux_emax(2,2,2,2,2), weight(2,2,2,2,2)
integer:: idx_edu(2), idx_wexp(2), idx_kage(2), idx_knum(2), idx_mdur(2)
end module state_space !1

module idxes 
integer:: t, i, j, k, l, r, iedu, imdur, iwexp, iknum, ikage, itype, imo
integer:: e, m, f, p, b, age, ibeta, iagent, agentchange
integer:: edu1, edu2, edu3, edu4
end module idxes !2

module params ! 63 parameters
! ue = (be0 + be1*medu + be2*finc + be3*ifhg + be4*age+ be5*m) * e
real:: betae(6) = (/3.86911,  0.06028,  0.04384, -1.03644, -1.96273, -0.50736/)
! um =(bm10 + bm11*mdur + bm12*f + bm13*p + bm14*qp + bm15*blk + bm16*hsp + bm17*ifcg) * m
real:: betam(8) = (/-9.72127, -0.01350,  9.08223,  7.97289, 0.13340, -0.08048,  0.02851,  0.40215/)
! uk = (bk0 + bk1*nsib + bk2*e + bk3*m + bk4*f + bk5*p) * N + bk6*N*N
real:: betak(9) = (/-0.34092, -0.00661, -0.73849,  0.32365, -0.46553, -0.25502, 0.47671, -0.15067, -0.04348/)
! us = bb1
real:: betab = -0.49709
! ul = (bp0 + bp1*mpar + bp2*e + bp3*blk + bp4*hsp) * p
real:: betaf(5) = (/-9.31468, 0.21548, -0.93829,  0.39708,  0.14961/)
real:: betap(5) = (/-9.31390, 0.03620,  0.45113,  0.22953,  0.02828/)
! ln(w) = mu0 + mu1*H/10 + mu2*(E-6)+ mu3*ifhsg + mu4*ifcg  + mu5*asv + mu6*blk + mu7*hsp
real:: muf(8) = (/7.57854, 0.39618,  1.24758,  0.10572,  0.11299,  0.32905, 0.04108,  0.00172/)
real:: mup(8) = (/7.14553,  0.08876,  1.17928, 0.08751, -0.00523,  0.28977, -0.00631, -0.00486/)
! VT = bt1 * E + bt2 * M + bt3 * H
real:: betat(3) = (/0.36869, 0.63724, 1.49821/)
! covariance matrix for errors
real:: sig_labf = 0.36170, sig_labp = 0.49206
! heterogeneity
! etah is the probability of being type 1 while am, ak and aw are associated with type 2
real:: am = 0.43161, ak = 0.09883, aw = 0.56280, ae = -1.07521, etah = 0.51781
! mprob = ld0 + ld1*age/10 + ld2*age*age
real:: lamdam(3) = (/2.58645,  0.85267, -0.39865/)
! ln(wh) = muh0 + muh1*age/10 + muh2*asv + muh3*(E-6) + muh4*black + muh5*hispa
real:: muh(6) = (/8.406403, .5440301, .0294111, .0924483, -.0547041, -.0097498/)
! bprob = ld0 + ld1*age/10 + ld2*blk + ld3*hsp + ld4*blk*age/10 + ld5*hsp*age/10
real:: lamda(6) = (/1.0091, 0.1437, -2.7039, -1.3734,  0.9640,  0.5380/)
real:: theta0(63), theta_new(63), theta_old(63), theta_grad(63)
end module params

module birth_prob
real:: probi, logprobt, logmprob, mprob
end module birth_prob 

module errors
! errors
real, allocatable:: norm_lab(:,:,:,:), err_lab(:,:,:,:), norm_all(:), uni_all(:), uni_lab(:,:,:,:)
real:: auxfp1(2,10), auxfp2(2,10), auxcdf, auxfp, emaxu1, emaxu0, emaxf1, emaxf0, emaxp1, emaxp0, emaxuf, emaxup, emaxfp
real:: errf, errp, errfr(10), errpr(10), uni1, logit1, check, aux_check
integer:: iseed = 12345
! mkl random number generator
integer brng, method, errcode, n_lab, n_k, n
end module errors

module inputs
integer:: alt_t, alt_set(5,24), alt_set12(12), alt_j
integer, dimension(25):: et, mt, ft, pt, bt
real:: data_array(28, 26500), data_array_t(26500, 28)
real:: blk, hsp, medu, nsib, mful, mpar, finc, pqual, asv, disc=0.9, tao = 1.
real, dimension(25):: wft, wpt, wht, edut, mdurt, wexpt, knumt, kaget, preg
real:: wt_fit(2), wh
end module inputs

module logl_array
real:: ue, um, uk, ul, ub, cspt_ps(10), cspt_ng(10), utl, lprobt, gbprobt, ufp(2)
real:: vri_ps(10,24), vri_ng(10,24), vri_single_ps(10,12), vri_single_ng(10,12), vmax_ps(10), vmax_ng(10), sumexp_ps(10), sumexp_ng(10)
real:: logpr(10), logit_prob, logl_it(25), emaxr_ps(10), emaxr_ng(10), logpr_ps(10), logpr_ng(10), logpr_ps1(10), logpr_ng1(10)
real:: wt_fit_emax(6,5,2), wf_emax_ps(6,5,10), wp_emax_ps(6,5,10), wf_emax_ng(6,5,10), wp_emax_ng(6,5,10)
real:: wh_emax(6), ue_emax(2,2,6), c_emax_ps(6,5,4,4,10,24), c_emax_ng(6,5,4,4,10,24), logit_prob1, logit_prob2
real:: ul_emax(24), um_emax(3,6,24), v_emax_ps(10,24), v_emax_ng(10,24), uk_emax(4,24), emax_m1, emax_m2
real:: probtf, probtp, lowerf, lowerp, lowerf1, lowerp1, lowerf2, lowerp2, hf, hp, valf(11), valp(11), sum1f, sum2f, sum1p, sum2p
real, allocatable:: xf(:), xp(:)
end module logl_array

module bhhh
integer:: iagent_grad, igrad, info, logmax_loc
integer:: ifder, inewton, linesearch, stop_flag, ibhhh, goback, cdf_flag, step_method, modifier
real:: delta(63), ll_theta(64), grad(63), hess(63,63), hinv(63,63), grad_indiv(1060,63), hess_indiv(1060,63,63), logli(64,1060), fisher(63)
real:: grad_reshape(63,1), ll_new, work(200), ipiv(200), start, finish, logli_t(1060,64), grad_debug(63)
real:: mome1(63), mome2(63), adam1, adam2, m1hat(63), m2hat(63), mome, debug1, debug2
real:: loglit_type(2), loglit_m, step(63), beta_sig(63)
real:: step_size, ll_old, nf_errors(63), penalty1, penalty2
end module bhhh

module parallel 
integer myid, nprocs, ierr
integer nagents, ncols  ! local number of agents and columns
integer, allocatable:: rcounts(:), flags(:) ! array of nsect's (for mpi_scatterv & mpi_gatrherv)
integer, allocatable:: displs(:) ! array of nsect's (for mpi_scatterv & mpi_gatrherv)
real, allocatable:: data_sect(:,:), data_sect_t(:,:) ! local section of sample for each process
real, allocatable:: sample(:,:,:) ! local section of sample reshaped
real, allocatable:: logli_sect(:,:) ! each element is loglikelihood contribution per agents for each parameter, size = (64, nagents)
end module parallel

