# DBT and Snowflake Project Guide

## Installation of DBT and Snowflake

### **1. Create a Snowflake Account**
*we will first create a snowflake account, create a database and schema and tables to load dummy data into it, we will then install dbt and create another schema to publish transformed data*
- Log in and create a new worksheet.
- Execute the following commands in the worksheet:

```sql
-- Create a database
CREATE DATABASE dbt_tutorial;

-- Grant privileges to the database for the current account
-- Note: A custom role needs to be created and assigned to the sysadmin account for best practices
GRANT ALL PRIVILEGES ON DATABASE dbt_tutorial TO ROLE accountadmin;

USE DATABASE dbt_tutorial;
```

### **2. Note the Following Values from Snowflake Account**

- **Database:** `dbt_tutorial` (current database used in Snowflake)
- **Password:** Password used to log in to your Snowflake account
- **Role:** `ACCOUNTADMIN` (role used within Snowflake)
- **Threads:** `10`
- **Type:** `snowflake`
- **User:** Find the username under the active profile in Snowflake.
- **Warehouse:** `COMPUTE_WH` (Snowflake warehouse)
- **Account:** Example: `https://ojinrdz-uz32624.snowflakecomputing.com`

### **3. Create a Virtual Environment and Install DBT**

- **Create Virtual Environment**:

  ```bash
  python -m venv venv  # Create a virtual environment
  venv\Scripts\activate  # Activate the virtual environment
  ```

- **Install Snowflake Connector and DBT**:

  ```bash
  python -m pip install dbt-snowflake
  pip list  # Verify installed packages
  ```

### **4. Initialize the DBT Project**

- Run the following commands:

  ```bash
  dbt init dbt_complete_project  # Initialize the project with a name
  ```

- Enter the required details:

  - Select `snowflake` as the database provider.
  - Choose `password` for the login method.
  - Enter the Snowflake account password, role, warehouse, database, schema, and number of threads.

- Verify the project setup:

  ```bash
  dbt debug
  ```

- Run the model:

  ```bash
  dbt run
  ```

  If errors occur (e.g., `dbt_project.yml` not found), navigate into the project folder and re-run the debug command.

- Deactivate and reactivate the virtual environment as needed:

  ```bash
  deactivate  # Deactivate
  activate  # Reactivate from the virtual environment directory
  ```

### **5. Config Files**

- A configuration file will be created in the root  to save profiles and credentials: `C://Users/<username>/.dbt`.

---

## DBT Project Structure

A DBT project consists of multiple folders, each serving a unique purpose:

### **1. Analyses (`analyses/`):**
- **Purpose:** Store SQL files for exploratory or one-off analyses that don’t create tables or views.
- **Example Use Case:** Ad-hoc reports like analyzing customer retention trends.
### **2. Logs (`logs/`):**
- **Purpose:** Store log files generated during `dbt run`, `dbt test`, or `dbt compile`.
- **Example Use Case:** Debugging a failed model build.
### **3. Macros (`macros/`):**
- **Purpose:** Store reusable SQL snippets or Jinja2 templates to extend DBT functionality.
- **Example:**
  ```sql
  {% macro current_timestamp() %}
    {{ dbt_utils.current_timestamp() }}
  {% endmacro %}
  ```
### **4. Models (`models/`):**
- **Purpose:** Core of the DBT project. Define SQL transformations and data models.
- **Materializations:** View, Table, Incremental, or Ephemeral.
- **Example Structure:**
  ```
  models/
    staging/
      stg_customers.sql
    marts/
      customer_mart.sql
  ```
### **5. Seeds (`seeds/`):**
- **Purpose:** Store static CSV files loaded into the database as tables.
- **Example Use Case:** Country code lookup table.
### **6. Snapshots (`snapshots/`):**
- **Purpose:** Capture historical states of tables for slowly changing dimensions (SCDs).
- **Example Use Case:** Tracking changes to customer addresses.
### **7. Tests (`tests/`):**
- **Purpose:** Store SQL files for testing data quality and reliability.
- **Example:**
  ```yaml
  - name: customer_id
    tests:
      - unique
      - not_null
  ```
### **8. Documentation (`docs/`):**
- **Purpose:** Store Markdown documentation for models and macros.
- **Example:**
  ```yaml
  models:
    - name: customer_mart
      description: "Aggregates customer purchase data."
  ```
### **9. Target (`target/`):**
- **Purpose:** Temporary folder for compiled SQL files and artifacts.
- **Example Use Case:** Inspect the SQL query generated for a model.
---

## Creating and Running Models

### **1. Creating a Table**

- Create a schema and table in Snowflake, using worksheet:
  ```sql
  CREATE SCHEMA raw;
  CREATE TABLE raw.Employee (
      EmployeeID INT,
      FirstName STRING,
      LastName STRING,
      BirthDate DATE,
      HireDate DATE,
      Salary DECIMAL(10, 2)
  );

  -- Insert sample data
  INSERT INTO raw.Employee (...);
  ```

### **2. Creating a Model**

- Define sources in a YAML file under `models/`. 
- Write the transformation logic in a `.sql` file (e.g., `employee_details.sql`). [View File](https://github.com/mihirajgaonkar/dbt_learnings/blob/main/models/directory_struct/intermediate/interm2_employee_details.sql)
- Run the model:
  ```bash
  dbt run
  ```

### **3. Materialization Options**
*materializations create the type of object under snowflake (View and Table), or define the data publishing strategy (Incremental and Ephemeral)*
*materializations can be defined in the model or can be defined in the source of yml*
- Default materializations:
  - `View`
  - `Table`
  - `Incremental`
  - `Ephemeral`
- Example Config:
  ```sql
  {{ config(materialized='table', schema='staging') }}
  ```

---

## Incremental Models

### **Purpose**

- Allows DBT to insert or update records since the last run.

### **Example Config**

```sql
{{ config(
    materialized='incremental',
    unique_key='id',
    merge_update_columns=['position', 'department']
) }}

{% if is_incremental() %}
    WHERE updated_at > (SELECT MAX(updated_at) FROM {{ this }})
{% endif %}
```
- *in the above code we are only updating the position and department column if new records are updated post max value in the updated_at column*
- *dbt checks and updates values based on the defined unique_key i.e id column* [View File](https://github.com/mihirajgaonkar/dbt_learnings/blob/main/models/incremental_example/incremental_employee.sql)
---

## Environment Variables
*here we have created a model to filter values where sales is > variable(sales_expectation), we can define the variable in the yml file or during runtime and reference the variable in the model* [View File](https://github.com/mihirajgaonkar/dbt_learnings/tree/main/models/environment_variable)
- **Defined in `dbt_project.yml`:**
  ```yaml
  vars:
    sales_expectation: 2000
  ```
- **Runtime Definition:**
  ```bash
  dbt run --vars '{"sales_expectation": 1000}'
  ```

---

## Jinja Templating
*To add csv files to datamodel , paste the csv files under the seed folder and exceute* 
  ```bash
  dbt seed
  ```

*in the below example we have used jinja to define the payment method and for loop and if else statement within sql to select the appropiate payment method* [View File](https://github.com/mihirajgaonkar/dbt_learnings/blob/main/models/raw_payments/order_payment_method_var.sql)
- **Features:** Loops, conditionals, variable setting, reusable functions.
- **Example:**
  ```sql
  {% set payment_methods = ["bank_transfer", "credit_card"] %}
  SELECT
      order_id,
      {% for method in payment_methods %}
      SUM(CASE WHEN payment_method = '{{ method }}' THEN amount END) AS {{ method }}_amount
      {% if not loop.last %}, {% endif %}
      {% endfor %}
  FROM {{ ref('raw_payments') }}
  GROUP BY 1
  ```

---

## Macros
*instead of using the jinja repeatadly in the models we can define it in a macro as a function and reference the function in our models as shown in the example below* 
[Tax macro](https://github.com/mihirajgaonkar/dbt_learnings/blob/main/macros/get_value_with_tax.sql)
[Tax model](https://github.com/mihirajgaonkar/dbt_learnings/blob/main/models/tax_calculation/tax_calculation_macro.sql)

### **Defining a Macro**

- Example:
  ```sql
  {% macro get_payment_methods() %}
  {{ return(["bank_transfer", "credit_card", "gift_card"]) }}
  {% endmacro %}
  ```

### **Using a Macro**

- Call the macro in models:
  ```sql
  SELECT
      order_id,
      {% for method in get_payment_methods() %}
      SUM(CASE WHEN payment_method = '{{ method }}' THEN amount END) AS {{ method }}_amount
      {% if not loop.last %}, {% endif %}
      {% endfor %}
  FROM {{ ref('raw_payments') }}
  GROUP BY 1
  ```
## dbt tests
## dbt documentation generation
---

This guide summarizes DBT project setup, structure, and usage. For further refinements or specific configurations, consult the DBT documentation or reach out for assistance!


