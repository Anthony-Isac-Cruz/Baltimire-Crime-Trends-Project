# 📘 README – Power BI Crime Trends Dashboard 

Official Link to dashboard:[https://app.powerbi.com/links/qfQm4qrCBB?ctid=f4808e7e-31ab-436b-8c3e-16ee61a6c8f9&pbi_source=linkShare&bookmarkGuid=47656250-9e0d-41e7-a925-5375a86fe91c]

---

## 🧠 Overview



This Power BI report analyzes crime patterns using a dataset named `CRIME_DATASET_CLEANED`. The goal is to understand how crimes vary over time, across demographics, and by offense types.

---

## 📊 Page 1 – Deep Dive & Tremd Overview with Measures

### Visuals Created:

1. **Line Chart** – Shows total crime trend over time (year and month)
2. **Matrix Table** – Breakdown of offenses by Gender and Age Group
3. **Stacked Column Chart** – Monthly crime counts by Age Group
4. **Donut Chart** – Gender share within each Offense Category

### Purpose:
This page gives a broad overview of when and who is involved in crimes. It focuses on temporal patterns and surface-level demographic insights.

### Purpose:
This page adds analytical depth:
- Tracks change over time (month-over-month and year-over-year)
- Highlights differences by demographics
- Helps detect patterns and outliers

---

## 🧮 DAX Measures Used

Created measures to enable:
- Total crime counts
- Percentages of total (e.g. % of total crimes by gender or age group)
- Month-over-month change
- Year-over-year change
- Average and median age

All measures were built using direct aggregations (e.g., count, divide, average) to avoid circular dependency issues.

---

## 📅 Date Table Usage

A proper Date Table was used to enable:
- Month-over-month and year-over-year comparisons
- Time-based filtering and sorting
- Accurate date-based calculations

It includes fields for:
- Year
- Month (as label)
- Month number
- Year-Month combo
- Day of Week and Day Number

A one-to-many relationship was created between the Date Table and `CRIME_DATASET_CLEANED` based on the crime date field.

---

## 📅 Day of Week Sorting

To sort days (e.g., Monday–Sunday) properly in visuals:
- Created a Day of Week column using formatted date
- Created a Day Number column (e.g., 1 = Monday)
- Used Power BI’s “Sort by Column” feature to apply sorting

---

## ✅ Best Practices Followed

- Measures written without referencing each other to avoid dependency errors
- Time intelligence built using a Date Table for flexibility
- Used ALLEXCEPT and ALL functions in measures to ensure correct group-level calculations
- Clear naming and formatting to ensure user-friendly visuals

---
