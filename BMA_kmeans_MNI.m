addpath /home/applications/spm12

maskimg = spm_vol('MNI152_2mm_mask.nii.gz');
mask = spm_read_vols(maskimg);
thelocs = find(mask);

for a = 1:numel(ExpImg)
    temp = ExpImg(a).ModActs;
    voxval(:,a) = temp(thelocs);
    clear temp
end

corrmat = corr(voxval);

for a = 2:8
[IDX{a-1},C{a-1},SUMD{a-1},D{a-1}] = kmeans(corrmat,a,'distance','correlation','emptyaction','singleton','start','cluster','replicates',1000, 'options',statset('MaxIter',1023));
T = clusterdata(
end

clear a maskimg
