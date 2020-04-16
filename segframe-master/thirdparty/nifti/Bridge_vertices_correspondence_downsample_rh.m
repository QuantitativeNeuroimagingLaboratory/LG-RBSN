
function out = Bridge_vertices_correspondence_downsample_rh(subjectID,subdir)

Subject1 = ['FreeSurfer_',subjectID];
Subject3 = 'FreeSurferMNI152';

Output_PATH = [subdir,'/',Subject1,'/FinalVertices'];
disp(Output_PATH)
if(exist(Output_PATH))
else
unix(['mkdir ',Output_PATH]);    
end

%ratiolist=[1 1 0.3 NaN 0.6 1 0.4 0.2 0.3 1 0.3 0.4 0.5 0.6 0.3 1 0.6 0.6 1 1 1 0.2 1 0.1 0.3 1 0.2 0.1 0.2 0.2 0.2 1 1 1 0.3];
%ratiolist=[0.6 1 0.3 NaN 0.6 1 0.2 0.1 0.3 0.5 0.2 0.2 0.3 0.3 0.2 1 0.3 0.4 1 0.5 0.6 0.1 0.3 0.1 0.1 1 0.1 0.1 0.1 0.1 0.1 1 1 1 0.2];
%ratiolist=[0.3 0.6 0.3 NaN 0.6 1 0.2 0.1 0.2 0.4 0.2 0.2 0.3 0.3 0.1 0.6 0.3 0.4 1 0.5 0.6 0.1 0.3 0.1 0.1 1 0.1 0.1 0.1 0.1 0.1 1 1 1 0.1]; %5939
%ratiolist=[0.1 1 0.3 NaN 0.6 1 0.1 0.1 0.1 0.4 0.2 0.2 0.2 0.3 0.1 0.3 0.4 0.4 1 0.5 0.6 0.1 0.3 0.1 0.1 1 0.1 0.1 0.1 0.1 0.1 1 1 1 0.2];% 0.1 downsample temporal lobe
%ratiolist=[0.6 1 0.3 NaN 0.6 1 0.3 0.1 0.3 0.5 0.2 0.3 0.3 0.4 0.3 1 0.4 0.4 1 0.6 0.6 0.1 0.5 0.1 0.2 0.6 0.2 0.1 0.1 0.2 0.1 1 1 1 0.2];
%            0.6 1 0.3 NaN 0.6 1 0.3 0.1 0.3 0.5 0.2 0.3 0.3 0.4 0.3 1 0.4 0.4 1 0.6 0.6 0.1 0.5 0.1 0.2 0.6 0.2 0.1 0.1 0.2 0.1 1 1 1 0.2
for i = [1:3,5:35]%[7,9]%[1,6,7,9,15,16,30,33,34]%[1:3,5:35]

        disp(['white ',num2str(i/35*100),'%'])
        name = num2str(i,'%03d');

        Path1 = [subdir,'/',Subject1,'/Vertices/aparc-rh-',name,'_CorrespondanceMap2MNI.label'];
        correspond1 = textread(Path1);
	fulllmnum = 2*length(correspond1);
	if fulllmnum < 2500
		ratio = 1;
	elseif fulllmnum <2750
		ratio = 0.6;
	elseif fulllmnum <3000
		ratio = 0.5;
	elseif fulllmnum <4000
		ratio = 0.4;
	elseif fulllmnum <4500
		ratio = 0.3;
	elseif fulllmnum <8500
		ratio = 0.2;
	else
		ratio = 0.1;
	end
	rati=num2str(ratio);

    if ratio==1
        unix(['cp ',subdir,'/',Subject1,'/Vertices/aparc-rh-',name,'_CorrespondanceMap2MNI.label ',Output_PATH,'/aparc-rh-',name,'_CorrespondanceMap2MNI_ds.label']);
    else


	fulllmnum = 2*length(correspond1);

        Pathds = [subdir,'/',Subject3,'_',rati,'/Vertices/aparc-rh-',name,'_CorrespondanceMap2MNI.label'];

        correspondds = textread(Pathds);
        dsindex = correspondds(:,1);

        source_points_length = size(correspond1,1);
        corr_n = 1;

        for k = 1:source_points_length

            mapped_index = correspond1(k,6); % sub map 2 MNI get the mapped vertice index
            source_index = correspond1(k,1);
            dsselect = ismember(source_index,dsindex);

            if (dsselect)
                   final_corr(corr_n,1:5) = correspond1(k,1:5);  % sub 2 MNI source points
                   final_corr(corr_n,6:10) = correspond1(k,6:10);  % SD 2 MNI target points  (sometimes search find more than one points)
                   corr_n = corr_n + 1;
            end

        end

        output_file = [Output_PATH,'/aparc-rh-',name,'_CorrespondanceMap2MNI_ds.label'];

        dlmwrite(output_file,final_corr,'delimiter',' ')
        clear final_corr
    end


end

%% Pial surface

for i = [1:3,5:35]%[7,9]%[1,6,7,9,15,16,30,33,34]%[1:3,5:35]

        disp(['pial ',num2str(i/35*100),'%'])
        name = num2str(i,'%03d');
        Path1 = [subdir,'/',Subject1,'/Vertices/pial-aparc-rh-',name,'_CorrespondanceMap2MNI.label'];

        correspond1 = textread(Path1);

	fulllmnum = 2*length(correspond1);
	if fulllmnum < 2500
		ratio = 1;
	elseif fulllmnum <2750
		ratio = 0.6;
	elseif fulllmnum <3000
		ratio = 0.5;
	elseif fulllmnum <4000
		ratio = 0.4;
	elseif fulllmnum <4500
		ratio = 0.3;
	elseif fulllmnum <8500
		ratio = 0.2;
	else
		ratio = 0.1;
	end
	rati=num2str(ratio);

    if ratio==1
        unix(['cp ',subdir,'/',Subject1,'/Vertices/pial-aparc-rh-',name,'_CorrespondanceMap2MNI.label ',Output_PATH,'/pial-aparc-rh-',name,'_CorrespondanceMap2MNI_ds.label']);
    else



        Pathds = [subdir,'/',Subject3,'_',rati,'/Vertices/pial-aparc-rh-',name,'_CorrespondanceMap2MNI.label'];

        correspondds = textread(Pathds);
        dsindex = correspondds(:,1);

        source_points_length = size(correspond1,1);
        corr_n = 1;

        for k = 1:source_points_length

            mapped_index = correspond1(k,6); % sub map 2 MNI get the mapped vertice index
            source_index = correspond1(k,1);
            dsselect = ismember(source_index,dsindex);

            if (dsselect)
                   final_corr(corr_n,1:5) = correspond1(k,1:5);  % sub 2 MNI source points
                   final_corr(corr_n,6:10) = correspond1(k,6:10);  % SD 2 MNI target points  (sometimes search find more than one points)
                   corr_n = corr_n + 1;
            end

        end

        output_file = [Output_PATH,'/pial-aparc-rh-',name,'_CorrespondanceMap2MNI_ds.label'];

        dlmwrite(output_file,final_corr,'delimiter',' ')
        clear final_corr
    end


end



