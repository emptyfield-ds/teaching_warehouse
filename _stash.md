# Martin's notes

Link to HackMD: https://hackmd.io/9dSQnonGQue0qoe6Yn0CZQ

# R Markdown Tables

From Malcolm:

> Repo location: https://github.com/malcolmbarrett/r_teaching_warehouse/tree/master/rmarkdown_tables

> * [x] You won't have to do a lot of setting up the problem here, as people will have seen a bit on Rmd at this point and appreciate the reproducibility.

> * [x] The exercises first explore markdown tables then `kable()`, but the main focus should be gtsummary

> * [x] I think it would be good to include a slide near the end about gt, maybe with the hex sticker, so I can point people to that

> * [x] I included the diabetes dataset, which I think will be good for slide examples. See the R Markdown whole game folder for a work up of this dataset that uses a couple of `gtsummary` tables

## Remove:

> * [ ] The R Markdown refresher and Visual R Markdown slides (I don't think I'll ever do this deck independent of Rmd, which introduces V RMD)
When to use tables/graphs? (I mostly teach people who need to know how to make tables not why)

> * [ ] The diabetes data slide (We use this lots, so this isn't the first time they'll be seeing these data)

> * [ ] The link to the dplyr slides

> * [ ] Remove the R Markdown and knitr hex stickers except for the knitr::kable() slide, and make the image a little bigger on that slide. (It's just inconsistent with how I normally do it.)

> * [ ] For the gtsummary slides, just show the hex on the first slide

> * [ ] Remove some of the focus on kable() output types, as it's generally better to let knitr decide. The pipe format might be useful for a slide to show what's happening. I also think you should show the table output itself (with the exception of maybe the pipe slide), not the underlying structure

> * [ ] Remove the Check with attr() part of the labelled slides

## Add/modify:

> * [ ] The your turn exercises, which should be interspersed throughout as appropriate. (See my other slides for examples.)

> * [ ] Also, make sure you are teaching to those. Right now, the following your turns don't have matching content: Your Turn 1, Your Turn 3, Your Turn 6. You don't need to cover everything for those, but that basically means adding a slide on 1) markdown tables/tables with Visual Rmd 2) tbl_cross() and 3) cross-referencing tables (which means connecting that idea to modify_caption() and using \@ref(tab:name-of-chunk).

> * [ ] An example of making labels using the list() style (which is what I tend to use; put that first, but keep your slides on the labelled package, as the idea is helpful)

> * [ ] I don't like the name d2. Can we call it table_data or something? I feel similarly about d3

> * [ ] Please run styler on the code chunks
