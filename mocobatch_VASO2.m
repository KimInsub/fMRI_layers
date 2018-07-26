numRuns=length(dir('S*.nii'));
cnt=1;
fileID = fopen('NT.txt','r');
nTRs = fscanf(fileID,'%f');
for runs=1:numRuns
    tt=['r' num2str(runs) '*_*.nii'];
    files=dir(tt);
    for bases=1:2
        nTR=nTRs(cnt);
        allFiles=[];
        for TR= 1:nTR
            base=files(bases).name;
            inst={[base ',' num2str(TR)]};
            allFiles=[allFiles; inst];
        end
        allFiles={allFiles};
        
        if bases ==1
            Dataprefix=['Not_Nulled_'];
        elseif bases==2
            Dataprefix=['Nulled_'];
        end
        matlabbatch{cnt}.spm.spatial.realign.estwrite.data = allFiles;
        matlabbatch{cnt}.spm.spatial.realign.estwrite.eoptions.quality = 1;
        matlabbatch{cnt}.spm.spatial.realign.estwrite.eoptions.sep = 1.2;
        matlabbatch{cnt}.spm.spatial.realign.estwrite.eoptions.fwhm = 1;
        matlabbatch{cnt}.spm.spatial.realign.estwrite.eoptions.rtm = 1;
        matlabbatch{cnt}.spm.spatial.realign.estwrite.eoptions.interp = 4;
        matlabbatch{cnt}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
        matlabbatch{cnt}.spm.spatial.realign.estwrite.eoptions.weight = {''};
        matlabbatch{cnt}.spm.spatial.realign.estwrite.roptions.which = [2 1];
        matlabbatch{cnt}.spm.spatial.realign.estwrite.roptions.interp = 4;
        matlabbatch{cnt}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
        matlabbatch{cnt}.spm.spatial.realign.estwrite.roptions.mask = 1;
        matlabbatch{cnt}.spm.spatial.realign.estwrite.roptions.prefix = Dataprefix;
        
        cnt=cnt+1;
        
    end
    
end

spm('defaults','FMRI')
spm_jobman('initcfg');
spm_jobman('run',matlabbatch);

exit
