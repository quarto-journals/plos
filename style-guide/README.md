# Style Guide from PLOS

Resources can be found at <https://plos.org/resources/writing-center/>

There are several journals which seems to have different guidelines

 - [PLOS Biology](https://journals.plos.org/plosbiology/s/submission-guidelines) 
 - [PLOS Climate](https://journals.plos.org/climate/s/submission-guidelines)
 - [PLOS Digital Health](https://journals.plos.org/digitalhealth/s/submission-guidelines)
 - [PLOS Computational Biology](https://journals.plos.org/ploscompbiol/s/submission-guidelines)
 - [PLOS Genetics](https://journals.plos.org/plosgenetics/s/submission-guidelines)
 - [PLOS Global Public Health](https://journals.plos.org/globalpublichealth/s/submission-guidelines)
 - [PLOS Medicine](https://journals.plos.org/plosmedicine/s/submission-guidelines)
 - [PLOS Neglected Tropical Diseases](https://journals.plos.org/plosntds/s/submission-guidelines)
 - [PLOS ONE](https://journals.plos.org/plosone/s/submission-guidelines)
 - [PLOS Pathogens](https://journals.plos.org/plospathogens/s/submission-guidelines)
 - [PLOS Sustainability and Transformation](https://journals.plos.org/sustainabilitytransformation/s/submission-guidelines)
 - [PLOS Water](https://journals.plos.org/water/s/submission-guidelines)

However, they all offer to download the same `plos-latex-template.zip` which resources are stored in this folder. 

## About files 

- `plos_latex_template.tex` is the main template file provided by the Journal, with `plot_latex_template.pdf` its rendered version.
- `plos_latex_template-commented.tex` is a working version with comments based on how we translated the template to Quarto extension. 
- `plos2015.bst` is the official BST file provided by the Journal

## Dev Notes


### References

PLOS does not expect `natbib` or `biblatex`, but just regular `\cite`

- https://tex.stackexchange.com/questions/376662/how-do-i-create-plosone-bib-references
- https://ulriklyngs.com/post/2021/12/02/how-to-adapt-any-latex-template-for-use-with-r-markdown-in-four-steps/