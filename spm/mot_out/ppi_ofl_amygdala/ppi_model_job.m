%-----------------------------------------------------------------------
% Job saved on 25-Mar-2020 15:51:59 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.util.exp_frames.files = '<UNDEFINED>';
matlabbatch{1}.spm.util.exp_frames.frames = '<UNDEFINED>';
matlabbatch{2}.spm.stats.fmri_spec.dir = '<UNDEFINED>';
matlabbatch{2}.spm.stats.fmri_spec.timing.units = 'secs';
matlabbatch{2}.spm.stats.fmri_spec.timing.RT = 2.87;
matlabbatch{2}.spm.stats.fmri_spec.timing.fmri_t = 40;
matlabbatch{2}.spm.stats.fmri_spec.timing.fmri_t0 = 20;
matlabbatch{2}.spm.stats.fmri_spec.sess.scans(1) = cfg_dep('Expand image frames: Expanded filename list.', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','files'));
matlabbatch{2}.spm.stats.fmri_spec.sess.cond = struct('name', {}, 'onset', {}, 'duration', {}, 'tmod', {}, 'pmod', {}, 'orth', {});
matlabbatch{2}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{2}.spm.stats.fmri_spec.sess.regress(1).name = 'PPI-Interaction';
matlabbatch{2}.spm.stats.fmri_spec.sess.regress(1).val = '<UNDEFINED>';
matlabbatch{2}.spm.stats.fmri_spec.sess.regress(2).name = 'Amy-BOLD';
matlabbatch{2}.spm.stats.fmri_spec.sess.regress(2).val = '<UNDEFINED>';
matlabbatch{2}.spm.stats.fmri_spec.sess.regress(3).name = 'US>noUS';
matlabbatch{2}.spm.stats.fmri_spec.sess.regress(3).val = '<UNDEFINED>';
matlabbatch{2}.spm.stats.fmri_spec.sess.multi_reg = '<UNDEFINED>';
matlabbatch{2}.spm.stats.fmri_spec.sess.hpf = 128;
matlabbatch{2}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{2}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{2}.spm.stats.fmri_spec.volt = 1;
matlabbatch{2}.spm.stats.fmri_spec.global = 'None';
matlabbatch{2}.spm.stats.fmri_spec.mthresh = 0.8;
matlabbatch{2}.spm.stats.fmri_spec.mask = '<UNDEFINED>';
matlabbatch{2}.spm.stats.fmri_spec.cvi = 'AR(1)';
matlabbatch{3}.spm.stats.fmri_est.spmmat(1) = cfg_dep('fMRI model specification: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{3}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{4}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{4}.spm.stats.con.consess{1}.tcon.name = 'Amy PPI Interaction';
matlabbatch{4}.spm.stats.con.consess{1}.tcon.weights = 1;
matlabbatch{4}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{4}.spm.stats.con.delete = 0;
