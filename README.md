# Public Library of Science (PLOS)

This Quarto format will help you create documents for the Public Library of Science (PLOS) journal. To learn more about PLOS publications, see [PLOS's writing center](https://plos.org/resources/writing-center/). For more about Quarto and how to use format extensions, see <https://quarto.org/docs/journals/>.

## Creating a New Article

You can use this as a template to create an article for the Public Library of Science (PLOS) journal. To do this, use the following command:

```quarto use template quarto-journals/plos```

This will install the extension and create an example qmd file and bibiography that you can use as a starting place for your article.

## Installation For Existing Document

You may also use this format with an existing Quarto project or document. From the quarto project or document directory, run the following command to install this format:

```quarto install extension quarto-journals/plos```

## Usage 

To use the format, you can use the format names `plos-pdf` and `plos-html`. For example:

```quarto render article.qmd --to plos-pdf```

or in your document yaml

```yaml
format:
  pdf: default
  plos-pdf:
    keep-tex: true    
```

You can view a preview of the rendered template at <https://quarto-journals.github.io/plos/>. 
