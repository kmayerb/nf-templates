# nf-templates

Some favorite NextFlow templates from scratch.


 I follow some conventions in all NextFlow scripts to encourage reusability.

* First, all script depend on a .csv manifest file. 
* Second, all non BASH code is stored in `bin/` and set to executable (e.g., chmod +x bin/script.py)


## `archive_by_group.nf`

Run many jobs and collect the result into pre-defined groups. See [`archive_by_group.nf`](https://github.com/kmayerb/nf-templates/blob/main/collect_groups_of_files/archive_by_group.nf)


### Objecive

Suppose you have two groups, one with 2 files and one with 3 files.  

```bash
inputs/
├── a1.txt
├── a2.txt
├── b1.txt
├── b2.txt
└── b3.txt 
```

All files must proceed through a common process, but the results must be processed separately or stored in 
separate archives. 

```bash
outputs/
├── a.tar.gz
└── b.tar.gz
```

where archives contain:

```bash
├── a.tar.gz
│   ├── a1.txt.lowercase.tsv
│   └── a2.txt.lowercase.tsv

├── b.tar.gz
│   ├── b1.txt.lowercase.tsv
│   ├── b2.txt.lowercase.tsv
│   └── b3.txt.lowercase.tsv
```

### Manifest

The project manifest (.csv) will provide the custom groupings using the group column:

```
name,group,filename
a1,a,inputs/a1.txt
a2,a,inputs/a2.txt
b1,b,inputs/b1.txt
b2,b,inputs/b2.txt
b3,b,inputs/b3.txt
```


### Workflow

For full details see the [`archive_by_group.nf`](https://github.com/kmayerb/nf-templates/blob/main/collect_groups_of_files/archive_by_group.nf)



### Ghist of the Solution

The solution is to put tuples into the output channel. 

```groovy
output: 
	tuple val(group), file("${filename}.lowercase.tsv") into output_channel

```

And then in recieving process recieve not one by a list of files `file_list`

```groovy 
set val(group), file_list from output_channel.groupTuple()
```



```bash
19:26 $ NXF_VER=20.07.1 nextflow run archive_by_group.nf -c local.config
N E X T F L O W  ~  version 20.07.1
Launching `archive_by_group.nf` [cheeky_goldstine] - revision: c0584e00b1
executor >  local (7)
[84/a7575e] process > make_lowercase (MAKE ALL LINES LOWERCASE)    [100%] 5 of 5 ✔
[6c/b66104] process > tar_files_by_group (COMNBINE FILES BY GROUP) [100%] 2 of 2 ✔
```

## `collect_by_group.nf`


For details see the [`collect_by_group.nf`](https://github.com/kmayerb/nf-templates/blob/main/collect_groups_of_files/collect_by_group.nf)

A variation on the theme, rather than archiving the group based collections may be passed to
another process with sorting based on name.

See `collect_by_group.nf`

The magic in both case is the [`.groupTuple()`]((https://www.nextflow.io/docs/latest/operator.html#grouptuple).) method that acts as collector on a channel. 


#### Note that file_list must be joined as a string so that it can be passed as commandline arguments

```groovy
concat.py ${file_list.join(' ')}
```

#### Note that the files can be sorted by their name

Compare the difference between

```groovy
output_channel.groupTuple().view()
````

```bash
[b, [b3, b2, b1], [/NF/nf-templates/twork/84/4e654ae91d90f7a2fed9900414b382/b3.txt.lowercase.tsv, /NF/nf-templates/twork/0b/978426beb8275b4dbfdc607ca29574/b2.txt.lowercase.tsv, /NF/nf-templates/twork/26/9afbf9f8d093474f0449bf549ccab4/b1.txt.lowercase.tsv]]
[a, [a2, a1], [/NF/nf-templates/twork/77/53e37391d761a0c511d6244503cc21/a2.txt.lowercase.tsv, /NF/nf-templates/twork/22/32dc53927e281f96cec58a81ea0ab4/a1.txt.lowercase.tsv]]
```

and 

```groovy
output_channel.groupTuple(sort: { it[1]} ).view()
```

```bash
[fa/445b52] process > make_lowercase (MAKE ALL LINES LOWERCASE) [100%] 5 of 5 ✔
[b, [b1, b2, b3], [/NF/nf-templates/twork/4b/04d7802a11ce4d6e4e624518cfd8bd/b1.txt.lowercase.tsv, /NF/nf-templates/twork/cf/00bf8c09d04db9e9cd52051f8f4c29/b2.txt.lowercase.tsv, /NF/nf-templates/twork/d6/56c2f87eaa8ded73e65621c5ba52dd/b3.txt.lowercase.tsv]]
[a, [a1, a2], [/NF/nf-templates/twork/46/b8261222ebe1bff83f092b7559e175/a2.txt.lowercase.tsv, /NF/nf-templates/twork/fa/445b5251f68b88482424bd3ea082c2/a1.txt.lowercase.tsv]]
```



