# Fantasy Football Data Analysis Project

## Introduction
This project is a comprehensive data engineering and visualization endeavor centered around fantasy football. It showcases skills in data extraction, transformation, and loading (ETL), as well as advanced data analytics and visualization. The pipeline includes Python scripts for pulling data from the Yahoo Sports API, storing data in AWS S3, loading it into a PostgreSQL database, and performing various data transformations and enrichments.

## Technologies Used
- Python
- Yahoo Sports API
- Amazon S3
- PostgreSQL
- SQL
- Tableau

## Project Structure
- `src/data_pull.py`: Script to extract data from Yahoo Sports API and upload data to AWS S3.
- `src/load_postgres.py`: Script to load data into PostgreSQL.
- `sql_scripts/`: Directory containing SQL tables, views, and procedures for data transformation and enrichment.
- `analytics/`: Analytics scripts for data analysis.
-  [Tableau workbook file showcasing league history visualization.](https://public.tableau.com/views/FANTASYRECORDBOOK/RECORDBOOK?:language=en-US&:display_count=n&:origin=viz_share_link)

## Installation and Setup
To set up this project, you will need Python installed on your machine, along with access to AWS S3 and PostgreSQL. Clone the repository and install the required Python packages:

```bash
git clone https://github.com/yourusername/fantasy-football.git
cd fantasy-football
pip install -r requirements.txt
```

## Tableau Visualization
Explore the visualizations of the league's history through the Tableau workbook.

Tableau Visualization for Fantasy Football Project
Download Tableau Workbook PDF

## Contributing
If you would like to contribute to this project, please fork the repository and submit a pull request.

## License
This project is licensed under the MIT License.

## Contact Information
For any inquiries or discussions about the project, feel free to contact me at anthonysfancher@gmail.com.

## Acknowledgments
A special thanks to Chris Altonji who contributed to the development of the Yahoo Fantasy API scripts.