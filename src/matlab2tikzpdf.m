function matlab2tikzpdf(varargin)
    %MATLAB2TIKZPDF    Save figure in native LaTeX (TikZ/Pgfplots).
    %   This function accepts same parameters as MATLAB2TIKZ, but automates the creation
    %   of cropped PDFs containing the TikZ vector graphics.
    %   
    %   Dependencies: All dependencies of MATLAB2TIKZPDF + pdflatex + pdfcrop command line
    %   utilities (for now I only care about Linux / Unix systems)
    %SEE ALSO: MATLAB2TIKZ
    
    
    % call MATLAB2TIKZ
    if (nargin == 0)
        error('Please provide at least the name of the tex file to contain the TikZ code');
    elseif (nargin == 1)
        [~, ~, ext] = fileparts(varargin{1});
        if (strcmp(ext,'.tex') || strcmp(ext,'.tikz'))
            varargin{2} = varargin{1};
            varargin{1} = 'filename';
        else
            varargin{2} = 'output.tex';
            varargin{1} = 'filename';
        end
    end
    
    matlab2tikz(varargin{:});

    % Create pdflatex file
    [~, basename, ext] = fileparts(varargin{2});
    texfile = [basename,'-out2pdf',ext];
    logtexfile = [basename,'-out2pdf.log'];
    auxtexfile = [basename,'-out2pdf.aux'];
    fid = fopen(texfile, 'wt');
    textext = sprintf(['\\documentclass{article}\n', ...
                       '\\usepackage{pgfplots}\n', ...
                       '\\pgfplotsset{compat=newest}\n', ...
                       '\\usetikzlibrary{plotmarks}\n', ...
                       '\\usepgfplotslibrary{patchplots}\n', ...
                       '\\usepackage{grffile}\n', ...
                       '\\usepackage{amsmath}\n', ...
                       '\\begin{document}\n', ...
                       '    \\input{',varargin{2},'}\n', ...
                       '\\end{document}\n']);
    fprintf(fid, '%s', textext);
    fclose(fid);
    
    % Call system utilities on tex file
    if (strcmp(ext,'.tex'))
        % Store the filename to process
        [~, basename, ~] = fileparts(texfile);    
        fileouttex = [basename, '.pdf'];
        filecrop = [basename, '-crop.pdf'];
        [~, basename, ~] = fileparts(varargin{2});
        fileout = [basename,'.pdf'];
        system(['pdflatex ',texfile,' && pdfcrop ',fileouttex,' && mv ',filecrop,' ',fileout,' && rm ',fileouttex],'-echo');
        system(['rm ',logtexfile,' ',auxtexfile]);
    else
        warning('Cannot convert .tikz files to PDFs! These can be imported manually.');
    end
end
