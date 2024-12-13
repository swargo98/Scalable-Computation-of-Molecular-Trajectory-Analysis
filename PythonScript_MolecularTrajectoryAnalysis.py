from pyspark import SparkContext, SparkConf
import os
import time

def validate_and_map(row):
    if len(row) >= 3:
        return (row[1], (row[0], row[2]))
    else:
        return None

def inside_accomodation(x_position, left, right):
    return float(x_position) > left and float(x_position) < right

def inside_incident(x_position, left, right):
    return float(x_position) > left and float(x_position) < right

def find_accomodation_or_incident(id, values, cutoff_index, accom_left, accom_right, inc_left, inc_right):
    if not values:
        return 0, 0

    sorted_values = sorted(values, key=lambda x: int(x[0]))
    accomodation_count = 0
    incident_count = 0
    current_state = -1

    for line, x_position in sorted_values:
        if inside_accomodation(x_position, accom_left, accom_right):
            if current_state == 1:
                accomodation_count += 1
                current_state = 2
        elif inside_incident(x_position, inc_left, inc_right):
            if current_state == 0 and int(line) <= cutoff_index:
                incident_count += 1
                current_state = 1
        else:
            current_state = 0

    return incident_count, accomodation_count

if __name__ == "__main__":
    start_time = time.time()
    printable_string = ''

    # File paths
    input_file_path = "myData (1).txt"
    input_with_line_numbers_file_path = "input_with_line_numbers.txt"
    output_file_path = "sbatch_output_" + input_file_path

    set_count_to_deduct_for_incident = 500

    # Add line numbers to input file
    with open(input_file_path, 'r') as infile, open(input_with_line_numbers_file_path, 'w') as outfile:
        for i, line in enumerate(infile):
            outfile.write(f"{i + 1} {line}")

    # Read lines and find NaN indices
    with open(input_with_line_numbers_file_path, 'r') as infile:
        lines = infile.readlines()

    nan_indices = [i for i, line in enumerate(lines) if 'NaN' in line]
    cutoff_index = nan_indices[0] if nan_indices else len(lines)

    if set_count_to_deduct_for_incident > 0 and len(nan_indices) >= set_count_to_deduct_for_incident:
        cutoff_index = nan_indices[-set_count_to_deduct_for_incident]

    # Configure Spark
    conf = SparkConf().setAppName("MolecularDynamics").setMaster("local")
    sc = SparkContext(conf=conf)

    # Process data with Spark
    accomodation_rdd = sc.textFile(input_with_line_numbers_file_path, minPartitions=64)

    header = accomodation_rdd.first()
    accomodation_data_rdd = accomodation_rdd.filter(lambda line: line != header).map(lambda line: line.split())
    accomodation_cleaned_rdd = accomodation_data_rdd.filter(lambda row: not any(value == "NaN" for value in row))

    accomodation_key_value_rdd = accomodation_cleaned_rdd.map(validate_and_map).filter(lambda x: x is not None)
    accomodation_grouped_rdd = accomodation_key_value_rdd.groupByKey()

    # Define planes
    accomodation_plane_Right = 73.2186
    accomodation_plane_Left = 2.709
    incident_plane_Right = accomodation_plane_Right + 20
    incident_plane_Left = accomodation_plane_Left - 20

    # Compute incidents and accommodations
    accomodation_rdd = accomodation_grouped_rdd.map(
        lambda x: [x[0], find_accomodation_or_incident(
            x[0], list(x[1]), cutoff_index,
            accomodation_plane_Left, accomodation_plane_Right,
            incident_plane_Left, incident_plane_Right)
        ]
    )

    total_counts = accomodation_rdd.map(lambda x: x[1]).reduce(lambda a, b: (a[0] + b[0], a[1] + b[1]))
    total_incidents, total_accommodations = total_counts
    overall_ratio = total_accommodations / total_incidents if total_incidents != 0 else "Infinity"

    # Display results
    printable_string += f"Total Accommodations: {total_accommodations}\n"
    printable_string += f"Total Incidents: {total_incidents}\n"
    printable_string += f"Overall Accommodation-to-Incident Ratio: {overall_ratio}\n"

    end_time = time.time()
    elapsed_time = end_time - start_time
    printable_string += f"Elapsed time: {elapsed_time:.6f} seconds\n"

    # Save the result to a file
    with open(output_file_path, 'w') as f:
        f.write(printable_string)

    # Stop Spark
    sc.stop()