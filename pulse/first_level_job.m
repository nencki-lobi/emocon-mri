%-----------------------------------------------------------------------
% Job saved on 23-Sep-2019 18:12:27 by cfg_util (rev $Rev: 380 $)
% pspm PsPM - Unknown
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.pspm{1}.first_level{1}.hp{1}.glm_hp_fc.modelfile = '<UNDEFINED>';
matlabbatch{1}.pspm{1}.first_level{1}.hp{1}.glm_hp_fc.outdir = '<UNDEFINED>';
matlabbatch{1}.pspm{1}.first_level{1}.hp{1}.glm_hp_fc.chan.chan_def = 0;
matlabbatch{1}.pspm{1}.first_level{1}.hp{1}.glm_hp_fc.timeunits.seconds = 'seconds';
matlabbatch{1}.pspm{1}.first_level{1}.hp{1}.glm_hp_fc.session.datafile = '<UNDEFINED>';
matlabbatch{1}.pspm{1}.first_level{1}.hp{1}.glm_hp_fc.session.missing.no_epochs = 0;
matlabbatch{1}.pspm{1}.first_level{1}.hp{1}.glm_hp_fc.session.data_design.condfile = '<UNDEFINED>';
matlabbatch{1}.pspm{1}.first_level{1}.hp{1}.glm_hp_fc.session.nuisancefile = {''};
matlabbatch{1}.pspm{1}.first_level{1}.hp{1}.glm_hp_fc.latency.fixed = 'fixed';
matlabbatch{1}.pspm{1}.first_level{1}.hp{1}.glm_hp_fc.bf.rf.hprf_fc1 = 1;
matlabbatch{1}.pspm{1}.first_level{1}.hp{1}.glm_hp_fc.bf.soa = 7.5;
matlabbatch{1}.pspm{1}.first_level{1}.hp{1}.glm_hp_fc.norm = false;
matlabbatch{1}.pspm{1}.first_level{1}.hp{1}.glm_hp_fc.filter.def = 0;
matlabbatch{1}.pspm{1}.first_level{1}.hp{1}.glm_hp_fc.exclude_missing.excl_no = 'No';
matlabbatch{1}.pspm{1}.first_level{1}.hp{1}.glm_hp_fc.overwrite = true;
matlabbatch{2}.pspm{1}.first_level{1}.contrast.modelfile(1) = cfg_dep('GLM for HP (fear-conditioning): Output File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','modelfile'));
matlabbatch{2}.pspm{1}.first_level{1}.contrast.datatype = 'cond';
matlabbatch{2}.pspm{1}.first_level{1}.contrast.con.conname = 'CSplus > CSminus';
matlabbatch{2}.pspm{1}.first_level{1}.contrast.con.convec = [1 -1];
matlabbatch{2}.pspm{1}.first_level{1}.contrast.deletecon = true;
matlabbatch{2}.pspm{1}.first_level{1}.contrast.zscored = false;
