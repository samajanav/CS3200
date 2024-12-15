-- CS3200: Database Design
-- GAD: The Genetic Association Database


-- Write a query to answer each of the following questions
-- Save your script file as cs3200_hw2_yourname.sql (no spaces)
-- Submit this file for your homework submission


use gad;


-- 1. 
-- Explore the content of the various columns in your gad table.
-- List all genes that are "G protein-coupled" receptors in alphabetical order by gene symbol
-- Output the gene symbol, gene name, and chromosome
-- (These genes are often the target for new drugs, so are of particular interest)

select gene, 
       gene_name, 
       chromosome
from gad
where gene_name = 'G protein-coupled'
order by gene asc;


-- 2. 
-- How many records are there for each disease class?
-- Output your list from most frequent to least frequent
 
select disease_class
from gad
order by disease_class desc;

-- 3. 
-- List all distinct phenotypes related to the disease class "IMMUNE"
-- Output your list in alphabetical order

select gad_id, 
	   phenotype, 
       disease_class
from gad
where disease_class = 'IMMUNE'
order by phenotype asc;

-- 4.
-- Show the immune-related phenotypes
-- based on the number of records reporting a positive association with that phenotype.
-- Display both the phenotype and the number of records with a positive association
-- Only report phenotypes with at least 60 records reporting a positive association.
-- Your list should be sorted in descending order by number of records
-- Use a column alias: "num_records"

select phenotype, count(*) as num_records
from gad 
where disease_class = 'IMMUNE' and association = 'Y'
group by phenotype
having COUNT(*) >= 60
order by num_records desc;

-- 5.
-- List the gene symbol, gene name, and chromosome attributes related
-- to genes positively linked to asthma (association = Y).
-- Include in your output any phenotype containing the substring "asthma"
-- List each distinct record once
-- Sort  gene symbol

select distinct 
		gene, 
		gene_name, 
        chromosome, 
        phenotype
from gad
where association = 'Y' and phenotype = "asthma"
order by gene;


-- 6. 
-- For each chromosome, over what range of nucleotides do we find
-- genes mentioned in GAD?
-- Exclude cases where the dna_start value is 0 or where the chromosome is unlisted.
-- Sort your data by chromosome. Don't be concerned that
-- the chromosome values are TEXT. (1, 10, 11, 12, ...)

select chromosome, 
	   min(dna_start) as min_nucleotide, 
	   max(dna_end) as max_nucleotide
from gad
where dna_start > 0 and chromosome is not null
group by chromosome
order by chromosome;

-- 7 
-- For each gene, what is the earliest and latest reported year
-- involving a positive association
-- Ignore records where the year isn't valid. (Explore the year column to determine what constitutes a valid year.)
-- Output the gene, min-year, max-year, and number of GAD records
-- order from most records to least.
-- Columns with aggregation functions should be aliased

select gene,
       min(year) as min_year,
       max(year) as max_year,
       count(*) as num_records
from gad
where association = 'Y'
	  and year is not null
	  and year > 0
group by gene
order by num_records desc;


-- 8. 
-- Which genes have a total of at least 100 positive association records (across all phenotypes)?
-- Give the gene symbol, gene name, and the number of associations
-- Use a 'num_records' alias in your query wherever possible


select gene, 
	   gene_name, 
       count(*) as num_records
from gad
where association = 'Y' 
group by gene, gene_name
having num_records >= 100 
order by num_records desc;

-- 9. 
-- How many total GAD records are there for each population group?
-- Sort in descending order by count
-- Show only the top five results based on number of records
-- Do NOT include cases where the population is blank

select population,
	   count(*) as num_records
from gad
where population is not null
group by population
order by num_records desc
limit 5;


-- 10. 
-- In question 5, we found asthma-linked genes
-- But these genes might also be implicated in other diseases
-- Output gad records involving a positive association between ANY asthma-linked gene and ANY disease/phenotype
-- Sort your output alphabetically by phenotype
-- Output the gene, gene_name, association (should always be 'Y'), phenotype, disease_class, and population
-- Hint: Use a subselect in your WHERE class and the IN operator

select 
    gene, 
    gene_name, 
    association, 
    phenotype, 
    disease_class, 
    population
from gad
where 
    association = 'Y' 
    and gene in (
        select 
            gene
        from 
            gad
        where 
            association = 'Y' 
            and phenotype like '%asthma%'
    )
order by phenotype asc;



-- 11. 
-- Modify your previous query.
-- Let's count how many times each of these asthma-gene-linked phenotypes occurs
-- in our output table produced by the previous query.
-- Output just the phenotype, and a count of the number of occurrences for the top 5 phenotypes
-- with the most records involving an asthma-linked gene (EXCLUDING asthma itself).


select 
    phenotype, 
	count(*) as num_records
from gad
where 
    association = 'Y' 
    and gene in (
        select 
            gene
        from 
            gad
        where 
            association = 'Y' 
            and phenotype like '%asthma%'
    )
group by phenotype
order by num_records desc
limit 5;  

-- 12. 
-- Interpret your analysis

-- a) Search the Internet. Does existing biomedical research support a connection between asthma and the top phenotype you identified above? Cite some sources and justify your conclusion!

/* There seems to be a relationship with asthma and type 1 diabetes (top phenotype identified).  
The nature of such relationship, however, remains complicated as there isn’t enough research proving the same. 
Several studies indicate that individuals with asthma are at an increased risk 
of developing autoimmune conditions like type 1 diabetes. 

For example, a systematic review and meta-analysis confirmed the bidirectional association 
between asthma and type 1 diabetes, with evidence suggesting children with asthma are more 
likely to develop immune-related conditions such as T1D. From the studies reviewed, 
the risk seems to be higher in children with asthma than adults. Although this area needs 
further exploration and the studies included as research needs to be thoroughly vetted 
for ethical concerns and biases, they reveal an overlap between these conditions, 
indicating a potential immune or genetic link.

Sources:

Zeng, Rong, et al. “Type 1 Diabetes and Asthma: A Systematic Review and Meta-Analysis of Observational Studies.” Endocrine, vol. 75, no. 3, 14 Jan. 2022, pp. 709–717, link.springer.com/article/10.1007/s12020-021-02973-x, https://doi.org/10.1007/s12020-021-02973-x. Accessed 27 Sept. 2024.
‌Hsiao, Yung-Tsung, et al. “Type 1 Diabetes and Increased Risk of Subsequent Asthma.” Medicine, vol. 94, no. 36, 1 Sept. 2015, pp. e1466–e1466, www.ncbi.nlm.nih.gov/pmc/articles/PMC4616625/, https://doi.org/10.1097/md.0000000000001466. Accessed 27 Sept. 2024.

-- b) Why might a drug company be interested in instances of such "overlapping" phenotypes?

Drug companies are interested in "overlapping phenotypes" like asthma and type 1 diabetes 
because these conditions might share biological pathways. This overlap opens 
opportunities for developing treatments targeting common mechanisms, 
which could improve efficacy and reduce side effects across multiple conditions. 
Understanding these connections also allows companies to refine personalized medicine strategies, 
tailoring therapies to patients with these co-occurring diseases.*/


-- CONGRATULATIONS!!: YOU JUST DID SOME LEGIT DRUG DISCOVERY RESEARCH! :-)
