%-----------------------------------------------------------------------
% Job saved on 15-Nov-2019 12:21:05 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7487)
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
matlabbatch{1}.spm.stats.con.spmmat = '<UNDEFINED>';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.name = 'cs difference';
matlabbatch{1}.spm.stats.con.consess{1}.tcon.weights = [1 0 -1 0];
matlabbatch{1}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.name = 'cs+ pmod';
matlabbatch{1}.spm.stats.con.consess{2}.tcon.weights = [0 1 0 0];
matlabbatch{1}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
% add manually
matlabbatch{1}.spm.stats.con.consess{3}.tcon.name = 'cs- pmod';
matlabbatch{1}.spm.stats.con.consess{3}.tcon.weights = [0 0 0 1];
matlabbatch{1}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
matlabbatch{1}.spm.stats.con.consess{4}.tcon.name = 'pmod difference';
matlabbatch{1}.spm.stats.con.consess{4}.tcon.weights = [0 1 0 -1];
matlabbatch{1}.spm.stats.con.consess{4}.tcon.sessrep = 'none';

matlabbatch{1}.spm.stats.con.delete = 1;
