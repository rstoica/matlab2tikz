function matlab2tikzpdf(varargin)
    %MATLAB2TIKZPDF    Save figure in native LaTeX (TikZ/Pgfplots).
    %   This function accepts same parameters as MATLAB2TIKZ, but automates the creation
    %   of cropped PDFs containing the TikZ vector graphics.
    %   
    %   Dependencies: All dependencies of MATLAB2TIKZPDF + pdflatex + pdfcrop command line
    %   utilities (for now I only care about Linux / Unix systems)
    %SEE ALSO: MATLAB2TIKZ
    
    if (nargin == 0)
        error('Please provide at least the name of the tex file to contain the TikZ code');
    elseif (nargin == 1)
        [~, ~, ext] = fileparts(varargin{1});
        if (strcmp(ext,'.tex') || strcmp(ext,'.tikz'))
            varargin{2} = varargin{1};
            varargin{1} = 'filename';
        else
            warning('Invalid filename %s! Expected latex of tikz formats.', varargin{1});
            varargin{2} = 'output.tex';
            varargin{1} = 'filename';
        end
    end
    
    % We want latex math formatting
    varargin{length(varargin)+1} = 'parseStringsAsMath';
    varargin{length(varargin)+1} = true;
    varargin{length(varargin)+1} = 'parseStrings';
    varargin{length(varargin)+1} = false;
    % call MATLAB2TIKZ to produce main tikz/tex figure
    matlab2tikz(varargin{:});

    % Create pdflatex file
    [path, basename, ext] = fileparts(varargin{2});
    if ~isempty(path)
        path = [path,filesep];
    end
    texfile = [path,basename,'-out2pdf',ext];
    % pdflatex references with respect to its cwd so leave the input line as given
    texinputfile = varargin{2};
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
                       '\\pagestyle{empty}\n', ...
                       '\\begin{document}\n', ...
                       '    \\input{',texinputfile,'}\n', ...
                       '\\end{document}\n']);
    fprintf(fid, '%s', textext);
    fclose(fid);
    
    % Store the filename to process
    [~, basename, ~] = fileparts(texfile);
    fileouttex = [basename, '.pdf'];
    filecrop = [basename, '-crop.pdf'];
    [~, basename, ~] = fileparts(varargin{2});
    fileout = [path,basename,'.pdf'];
    filematlabfig = [path,basename,'.fig'];
    system(['pdflatex ',texfile,' && pdfcrop ',fileouttex,' && mv ',filecrop,' ',fileout,' && rm ',fileouttex],'-echo');
    system(['rm ',logtexfile,' ',auxtexfile]);
    % Store the fig file for MATLAB reuse as well
    savefig(filematlabfig);
end
