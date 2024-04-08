import logging
import sys
from datetime import datetime

from pyspark.sql import SparkSession
from pyspark.sql.functions import *
from pyspark.sql import functions as f

# Logging configuration
formatter = logging.Formatter('[%(asctime)s] %(levelname)s @ line %(lineno)d: %(message)s')
handler = logging.StreamHandler(sys.stdout)
handler.setLevel(logging.INFO)
handler.setFormatter(formatter)
logger = logging.getLogger()
logger.setLevel(logging.INFO)
logger.addHandler(handler)

dt_string = datetime.now().strftime("%Y_%m_%d_%H_%M_%S")
AppName = "NewYorkTaxiData"


def main(args):

    input_file = args[1]
    output_folder = args[2]

    # Create Spark Session
    spark = SparkSession \
        .builder \
        .appName(AppName + "_" + str(dt_string)) \
        .getOrCreate()

    spark.sparkContext.setLogLevel("INFO")
    logger.info("Starting spark application")

    logger.info("Reading Parquet file from S3")
    ny_taxi_df = spark.read.parquet(input_file)

    # Beef up the data by duplicating it 100 times
    for i in range(100):
        ny_taxi_df = ny_taxi_df.union(ny_taxi_df)
        if i > 0 and i % 10 == 0:
            logger.info("Repartitioning")
            ny_taxi_df = ny_taxi_df.repartition(i)

    logger.info("Total number of records: " + str(ny_taxi_df.count()))

    #logger.info("Write New York Taxi data to S3 transform table")
    ny_taxi_df.write.mode("overwrite").parquet(output_folder)

    logger.info("Ending spark application")
    # end spark code
    spark.stop()

    return None


if __name__ == "__main__":
    print(len(sys.argv))
    if len(sys.argv) != 3:
        print("Usage: spark-etl [input-folder] [output-folder]")
        sys.exit(0)

    main(sys.argv)
