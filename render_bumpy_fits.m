% Author: Gizem Kucukoglu
% April 2015

function render_bumpy_fits(fit_results)

%% Render bumpy spheres using the fit results
% Gloss level: 0,10,20...,100 % gloss
% bump_level: 0.4 to 4.4 in increments of 0.4
% needs mat file of best fit parameter values as an 11x3 matrix
% rows: [1-matte, 2-10%, 3-20%, ..., 11- 100% gloss]
% cols: [rho_s rho_d alpha]

%scene14.hdr

load(fit_results)
for lf = 1:2
    for bump = 2:10
        for gloss = 2:10
            
            row_no = gloss;
            var = correctedForNorm(row_no,:);
            
            ro_s = ['300:',num2str(var(1)),' 800:',num2str(var(1))];
            mean_diffuse = mean(correctedForNorm(:,2));
            ro_d = ['300:',num2str(mean_diffuse),' 800:',num2str(mean_diffuse)];
            alphau = var(3);
            
            mycell = {ro_s, ro_d, alphau};
            
            T = cell2table(mycell, 'VariableNames', {'ro_s' 'ro_d' 'alphau'});
            writetable(T,'/scratch/gk925/render_stimuli_5by5/bumpy_fitrender_Conditions.txt','Delimiter','\t')
            
            % Set preferences
            setpref('RenderToolbox3', 'workingFolder', '/scratch/gk925/render_stimuli_5by');
            
            % use this scene and condition file.
            parentSceneFile = ['GBMeshD',num2str(bump),'G',num2str(gloss),'L',num2str(lf),'.dae']
            conditionsFile = 'bumpy_fitrender_Conditions.txt';
            %     mappingsFile = ['bumpy',bump_level,'_5by5_correctCameraDistDefaultMappings.txt'];
            if lf == 1
                mappingsFile = 'MeshLF1DefaultMappings.txt'
            else
                mappingsFile = 'MeshLF2DefaultMappings.txt'
            end
            
            % Make sure all illuminants are added to the path.
            addpath(genpath(pwd))
            
            % which materials to use, [] means all
            hints.whichConditions = [];
            
            % Choose batch renderer options.
            hints.imageWidth = 550;
            hints.imageHeight = 550;
            datetime=datestr(now);
            datetime=strrep(datetime,':','_'); %Replace colon with underscore
            datetime=strrep(datetime,'-','_');%Replace minus sign with underscore
            datetime=strrep(datetime,' ','_');%Replace space with underscore
            hints.recipeName = ['GBMeshD',num2str(bump),'G',num2str(gloss),'L',num2str(lf),'-' datetime];
            
            ChangeToWorkingFolder(hints);
            
            %comment all this out
            toneMapFactor = 10;
            isScale = true;
            
            for renderer = {'Mitsuba'}
                
                % choose one renderer
                hints.renderer = renderer{1};
                
                % make 3 multi-spectral renderings, saved in .mat files
                nativeSceneFiles = MakeSceneFiles(parentSceneFile, conditionsFile, mappingsFile, hints);
                radianceDataFiles = BatchRender(nativeSceneFiles, hints);
                
                % condense multi-spectral renderings into one sRGB montage
                montageName = sprintf('GBMeshD%sG%sL%s', num2str(bump), num2str(gloss), num2str(lf));
                montageFile = [montageName '.png'];
                [SRGBMontage, XYZMontage] = ...
                    MakeMontage(radianceDataFiles, montageFile, toneMapFactor, isScale, hints);
                
                % display the sRGB montage
                % ShowXYZAndSRGB([], SRGBMontage, montageName);
            end
            
            
        end
    end
end



