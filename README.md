# grades_and_employer_learnings

This repository contains replication files for the paper: "Grades and Employer Learning" by Anne Toft Hansen, Ulrik Hvidman and Hans Henrik Sievertsen

## Files

The repository contains three folders:

1. **adofiles**: contains Stata .ado files that defines functions (programs) written by the authors.
2. **dofiles**: contains two folders of Stata .do files and two .do files. 
	* the file *globals.do* specifies the working directory, globals etc.
	* the folder *databuild* contains Stata .do files that creates the dataset used for analyses based on files from Statistics Denmark.
	* the folder *analysis* contains Stata .do files that creates all tables and figures for the manuscript.
3. **grade combinations** contains two files. 
	* *combinations.py* calculates the number of combinations that can lead to a certain GPA
	* *create_charts_in_R* creates visualizations using the results combinations.py.

