
% Based On: https://www.sharelatex.com/templates/cv-or-resume/smart-twenty-seconds-cv

\ProvidesClass{twentysecondcv}[2015/02/28 CV class]
\LoadClass{article}
\NeedsTeXFormat{LaTeX2e}

%----------------------------------------------------------------------------------------
%   REQUIRED PACKAGES
%----------------------------------------------------------------------------------------

\RequirePackage[quiet]{fontspec}
\RequirePackage[sfdefault]{ClearSans}

\def\arrow#1{\pspicture[shift=2pt](#1,0)\psline{->}(#1,0)\endpspicture}

\usepackage{pstricks}

\usepackage{fontawesome}
\defaultfontfeatures{Ligatures={NoCommon, NoDiscretionary, NoHistoric, NoRequired, NoContextual}}

\usepackage{xltxtra}

\usepackage{graphicx}

\RequirePackage{tikz}
\RequirePackage{xcolor}
\RequirePackage[absolute,overlay]{textpos}
\RequirePackage{ragged2e}
\RequirePackage{etoolbox}
\RequirePackage{ifmtarg}
\RequirePackage{ifthen}
\RequirePackage{pgffor}
\RequirePackage{marvosym}
\RequirePackage{parskip}

\usepackage{enumitem}
\setlist[itemize]{leftmargin=*, itemsep=1pt, topsep=5pt}

\RequirePackage[hidelinks]{hyperref}
\hypersetup{
    pdftitle={},
    pdfauthor={},
    pdfsubject={},
    pdfkeywords={},
    colorlinks=false,           % no lik border color
    allbordercolors=white       % white border color for all
}

\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

\ifxetex
  \usepackage{letltxmacro}
  \setlength{\XeTeXLinkMargin}{1pt}
  \LetLtxMacro\SavedIncludeGraphics\includegraphics
  \def\includegraphics#1#{% #1 catches optional stuff (star/opt. arg.)
    \IncludeGraphicsAux{#1}%
  }%
  \newcommand*{\IncludeGraphicsAux}[2]{%
    \XeTeXLinkBox{%
      \SavedIncludeGraphics#1{#2}%
    }%
  }%
\fi

%----------------------------------------------------------------------------------------
%   COLOURS
%----------------------------------------------------------------------------------------

\definecolor{white}{RGB}{255,255,255}
\definecolor{gray}{HTML}{4D4D4D}
\definecolor{sidecolor}{HTML}{E7E7E7}
\definecolor{mainblue}{HTML}{86A9C1}
\definecolor{maingray}{HTML}{B9B9B9}

\definecolor{pblue}{HTML}{0395DE}

\definecolor{darkgray}{HTML}{333333}
\definecolor{gray}{HTML}{4D4D4D}
\definecolor{lightgray}{HTML}{999999}
\definecolor{green}{HTML}{C2E15F}
\definecolor{orange}{HTML}{FDA333}
\definecolor{purple}{HTML}{D3A4F9}
\definecolor{red}{HTML}{FB4485}
\definecolor{blue}{HTML}{6CE0F1}
\definecolor{pblue}{HTML}{0395DE}
\definecolor{materialpurple}{HTML}{9C27B0}
\definecolor{materialindigo}{HTML}{3F51B5}
\definecolor{materialblue}{HTML}{2196F3}
\definecolor{materialcyan}{HTML}{00BCD4}
\definecolor{materialteal}{HTML}{009688}
\definecolor{materialgreen}{HTML}{4CAF50}
\definecolor{materiallime}{HTML}{CDDC39}
\definecolor{materialamber}{HTML}{FFC107}
\definecolor{materialbrown}{HTML}{795548}
\definecolor{materialred}{HTML}{FF4436}
\definecolor{materialorange}{HTML}{FF5722}
\definecolor{linkedin}{HTML}{0085AE}
\definecolor{test}{HTML}{0077be}
\definecolor{yt}{HTML}{c71610}

\ifdefined\@cv@print
  \colorlet{green}{gray}
  \colorlet{orange}{gray}
  \colorlet{purple}{gray}
  \colorlet{red}{gray}
  \colorlet{blue}{gray}
  \colorlet{fillheader}{white}
  \colorlet{header}{gray}
\else
  \colorlet{fillheader}{white}
  \colorlet{header}{gray}
\fi
\colorlet{textcolor}{gray}
\colorlet{headercolor}{pblue}

%----------------------------------------------------------------------------------------
%   MISC CONFIGURATIONS
%----------------------------------------------------------------------------------------

% \renewcommand{\bfseries}{\color{black}} % Make \textbf produce coloured text instead

\pagestyle{empty} % Disable headers and footers

\setlength{\parindent}{0pt} % Disable paragraph indentation

% --------------------------------------------------------------------------------------
%   FONTS
%-------------------------------------------------------------------------------------
\newfontfamily\headingfont[Path = fonts/]{segoeuib.ttf}

%----------------------------------------------------------------------------------------
%   SIDEBAR DEFINITIONS
%----------------------------------------------------------------------------------------

\setlength{\TPHorizModule}{1cm} % Left margin
\setlength{\TPVertModule}{1cm} % Top margin

\newlength\imagewidth
\newlength\imagescale
\pgfmathsetlength{\imagewidth}{5cm}
\pgfmathsetlength{\imagescale}{\imagewidth/600}

\newcommand{\profilesection}[2]{\vspace{8pt}{\color{black!80} \huge #1 \rule[0.15\baselineskip]{#2}{1pt}}}

% Define custom commands for CV info
\newcommand{\cvdate}[1]{\renewcommand{\cvdate}{#1}}
\newcommand{\cvlinkedin}[1]{\renewcommand{\cvlinkedin}{#1}}
\newcommand{\cvgithub}[1]{\renewcommand{\cvgithub}{#1}}
\newcommand{\cvmail}[1]{\renewcommand{\cvmail}{#1}}
\newcommand{\cvnumberphone}[1]{\renewcommand{\cvnumberphone}{#1}}
\newcommand{\cvaddress}[1]{\renewcommand{\cvaddress}{#1}}
\newcommand{\cvsite}[1]{\renewcommand{\cvsite}{#1}}
\newcommand{\aboutme}[1]{\renewcommand{\aboutme}{#1}}
\newcommand{\profilepic}[1]{\renewcommand{\profilepic}{#1}}
\newcommand{\cvname}[1]{\renewcommand{\cvname}{#1}}
\newcommand{\cvjobtitle}[1]{\renewcommand{\cvjobtitle}{#1}}

% Command for printing the contact information icons
\newcommand*\icon[1]{\tikz[baseline=(char.base)]{\node[shape=circle,draw,inner sep=1pt, fill=mainblue,mainblue,text=white] (char) {#1};}}

% Command for printing skill progress bars
\newcommand\skillitems[1]{
    \foreach [count=\i] \x in {#1}{
      \footnotesize{\x}
      \vspace{2pt} \\
    }
}

\newcommand\programming[1]{
  \renewcommand{\programming}{
    \skillitems{#1}
  }
}

\newcommand\iac[1]{
  \renewcommand{\iac}{
    \skillitems{#1}
  }
}

\newcommand\oses[1]{
  \renewcommand{\oses}{
    \skillitems{#1}
  }
}

\newcommand\platforms[1]{
  \renewcommand{\platforms}{
    \skillitems{#1}
  }
}

\newcommand\cicd[1]{
  \renewcommand{\cicd}{
    \skillitems{#1}
  }
}

\newcommand\monitoring[1]{
  \renewcommand{\monitoring}{
    \skillitems{#1}
  }
}

\newcommand\alerting[1]{
  \renewcommand{\alerting}{
    \skillitems{#1}
  }
}

\newcommand\projects[1]{
  \renewcommand{\projects}{
    \footnotesize{#1}
  }
}

\newcommand\qualifications[1]{
  \renewcommand{\qualifications}{
    \footnotesize{#1}
  }
}

%----------------------------------------------------------------------------------------
%  SIDEBAR LAYOUT
%----------------------------------------------------------------------------------------

\newcommand{\makeprofile}{
  \begin{tikzpicture}[remember picture,overlay]
    \footnotesize\node [rectangle, fill=sidecolor, anchor=north, minimum width=9cm, minimum height=\paperheight+1cm] (box) at (-5cm,0.5cm){};
  \end{tikzpicture}

  %------------------------------------------------

  \begin{textblock}{6}(0.5, 0.2)

    %------------------------------------------------

    \vspace{4mm}
    {\Huge\color{pblue}\cvname}

    \vspace{2mm}

    %------------------------------------------------

    {\large\color{black!80}\cvjobtitle}

    %------------------------------------------------

    \vspace{4mm}
    \renewcommand{\arraystretch}{2}
    \begin{tabular}{p{0.5cm} @{\hskip 0.25cm}p{5cm}}
      \ifthenelse{\equal{\cvnumberphone}{}}{}{
          {$
              \begin{array}{l}
              \hspace{4mm} \Huge \textnormal{\faMobile}
              \end{array}
              $}
            & \cvnumberphone\\}

      \ifthenelse{\equal{\href{\cvsite}{\cvsite}}{}}{}{
            {$
              \begin{array}{l}
              \hspace{-1.8mm} \huge \textnormal{\textcolor{test}{\faGlobe}}
              \end{array}
              $}
            & \href{http://\cvsite}{\cvsite} \\}
      \ifthenelse{\equal{\cvmail}{}}{}{
            {$
              \begin{array}{l}
              \hspace{-2.5mm} \huge \textnormal{\textcolor{yt}{\faEnvelopeO}}
              \end{array}
              $}
            & \href{mailto:\cvmail}{\cvmail} \\}

       \ifthenelse{\equal{\cvlinkedin}{}}{}{
            {$
              \begin{array}{l}
              \hspace{-1.6mm} \huge \textnormal{\textcolor{linkedin}{\faLinkedin}}
              \end{array}
              $} & \href{https://www.linkedin.com\cvlinkedin}{\cvlinkedin} \\
            }
        \ifthenelse{\equal{\cvgithub}{}}{}{
            {$
              \begin{array}{l}
              \hspace{-1.5mm} \huge \textnormal{\faGithub}
              \end{array}
              $} & \href{https://www.github.com/\cvgithub}{\cvgithub} \\
            }

    \end{tabular}

    %------------------------------------------------
    \vspace{2.5mm}
    \profilesection{Skills}{3cm}

    \skills

    %------------------------------------------------

    {\small \textbf{Programming Languages}} \\
    \programming \\
    {\small \textbf{Infrastructure as Code (IaC)}} \\
    \iac \\
    {\small \textbf{Operating Systems}} \\
    \oses \\
    {\small \textbf{Platforms}} \\
    \platforms \\
    {\small \textbf{CI/CD}} \\
    \cicd \\
    {\small \textbf{Monitoring}} \\
    \monitoring \\
    {\small \textbf{Alerting}} \\
    \alerting

  \end{textblock}
}

\newcommand{\makeprofiletwo}{
  \begin{tikzpicture}[remember picture,overlay]
    \footnotesize\node [rectangle, fill=sidecolor, anchor=north, minimum width=9cm, minimum height=\paperheight+1cm] (box) at (-5cm,0.5cm){};
  \end{tikzpicture}

  \begin{textblock}{6}(0.5, 0.2)

    \vspace{4mm}
    {\Huge\color{pblue}\cvname}

    \vspace{2mm}
    {\large\color{black!80}\cvjobtitle}

    \profilesection{Projects}{21mm}

    \projects

    \vspace{50pt}
    \profilesection{Qualifications}{3mm}

    \qualifications

  \end{textblock}
}

%----------------------------------------------------------------------------------------
%   COLOURED SECTION TITLE BOX
%----------------------------------------------------------------------------------------

% Command to create the rounded boxes around the first three letters of section titles
% \newcommand*\round[2]{%
%   \tikz[baseline=(char.base)]\node[anchor=north west, draw,rectangle, rounded corners, inner sep=1.6pt, minimum size=5.5mm, text height=3.6mm, fill=#2,#2,text=white](char){#1};%
% }

\def\@sectioncolor#1#2#3{%
  {%
    \color{pblue} #1#2#3%
  }%
}


\renewcommand{\section}[1]{
  \par\vspace{\parskip}
  {%
    \LARGE\headingfont\color{headercolor}%
    #1%
  }
  \vspace{-12pt}
}

\renewcommand{\subsection}[1]{
  \par\vspace{.5\parskip}{%
    \small\headingfont\color{headercolor} #1%
  }
  \par\vspace{.25\parskip}%
}

\pagestyle{empty}

%----------------------------------------------------------------------------------------
%   Summary
%----------------------------------------------------------------------------------------

\newcommand{\summary}[1]{%
  \parbox[t]{0.98\textwidth}{%
    \begin{flushleft}
    \ifblank{#1}{}\small{#1} \\%
    \end{flushleft}
  }
}

%----------------------------------------------------------------------------------------
%   LONG LIST ENVIRONMENT
%----------------------------------------------------------------------------------------

\setlength{\tabcolsep}{0pt}

% New environment for the long list
\newenvironment{twenty}{
  \begin{tabular*}{\textwidth}{@{\extracolsep{\fill}}ll}
}{
  \end{tabular*}
}

%\twentyitem{<date from>}{<date to>}{<title>}{<company>}{<location>}{<description>}{<responsibilities>}{<key achievements>}
\newcommand{\twentyitem}[9][4pt]{%
  \parbox[t]{0.98\textwidth}{%
    \begin{flushleft}
    \vspace{#1}
    \textbf{\large #4} \\ % Location
    \noindent
    {\textbf{\normalsize #5 (#2 - #3)}} \hfill \ifblank{#6}{}{\textbf{\normalsize #6}} \\ % Company (DateFrom - DateTo) Location
    \vspace{5pt}\ifblank{#7}{}{\small #7 \vspace{5pt} \\} % Description
    \ifblank{#8}{}{\textbf{\normalsize Responsibilities: -}{\small #8 \vspace{5pt}}} % Responsibilities
    \ifblank{#9}{}{\textbf{\normalsize Key Achievements: -}{\small #9}} % Key Achievements
    \end{flushleft}
  }
}

%----------------------------------------------------------------------------------------
%   SMALL LIST ENVIRONMENT
%----------------------------------------------------------------------------------------

\setlength{\tabcolsep}{0pt}

% New environment for the small list
\newenvironment{twentyshort}{%
  \begin{tabular*}{\textwidth}{@{\extracolsep{\fill}}ll}
}{%
  \end{tabular*}
}

\newcommand{\twentyitemshort}[2]{%
  #1&\parbox[t]{0.98\textwidth}{%
    #2%
  }
}

%----------------------------------------------------------------------------------------
%   MARGINS AND LINKS
%----------------------------------------------------------------------------------------

\RequirePackage[left=6cm,top=0.1cm,right=1cm,bottom=0.1cm,nohead,nofoot]{geometry}


\usepackage{smartdiagram}
\smartdiagramset{
    bubble center node font = \footnotesize,
    bubble node font = \footnotesize,
    % specifies the minimum size of the bubble center node
    bubble center node size = 0.5cm,
    %  specifies the minimum size of the bubbles
    bubble node size = 0.5cm,
    % specifies which is the distance among the bubble center node and the other bubbles
    distance center/other bubbles = 0.3cm,
    % sets the distance from the text to the border of the bubble center node
    distance text center bubble = 0.5cm,
    % set center bubble color
    bubble center node color = pblue,
    % define the list of colors usable in the diagram
    set color list = {lightgray, materialcyan, orange, green, materialorange, materialteal, materialamber, materialindigo, materialgreen, materiallime},
    % sets the opacity at which the bubbles are shown
    bubble fill opacity = 0.6,
    % sets the opacity at which the bubble text is shown
    bubble text opacity = 1,
}
