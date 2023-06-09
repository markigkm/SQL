/*

Cleaning Data in SQL Queries

*/


Select *
From PPT2..Nashville

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


Select SaleDateConverted, CONVERT(Date, SaleDate)
From PPT2..Nashville

UPDATE PPT2..Nashville
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE PPT2..Nashville
ADD SaleDateConverted Date;

UPDATE PPT2..Nashville
SET SaleDateConverted = CONVERT(Date, SaleDate)
 
 
 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM PPT2..Nashville
--WHERE PropertyAddress is NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PPT2..Nashville a
JOIN PPT2..Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PPT2..Nashville a
JOIN PPT2..Nashville b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-----Splitting Property Address

SELECT PropertyAddress
FROM PPT2..Nashville;

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PPT2..Nashville

ALTER TABLE PPT2..Nashville
ADD Property_Address nvarchar(255)

UPDATE PPT2..Nashville
SET Property_Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PPT2..Nashville
ADD City nvarchar(255)
-- ALTER TABLE INTO PROPERTY_CITY INSTEAD OF CITY

UPDATE PPT2..Nashville
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))




----- Splitting Owner Address

SELECT OwnerAddress
FROM PPT2..Nashville

SELECT 
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
FROM PPT2..Nashville

ALTER TABLE PPT2..Nashville
ADD Owner_Address nvarchar(255);

	UPDATE PPT2..Nashville
	SET Owner_Address = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3);

ALTER TABLE PPT2..Nashville
ADD Owner_City nvarchar(255);

	UPDATE PPT2..Nashville
	SET Owner_City = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2);

ALTER TABLE PPT2..Nashville
ADD Owner_State nvarchar(255);

	UPDATE PPT2..Nashville
	SET Owner_State = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1);

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PPT2..Nashville
GROUP BY SoldAsVacant
ORDER BY 2

--USING CASE STATEMENT

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM PPT2..Nashville


UPDATE PPT2..Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM PPT2..Nashville

)
DELETE 
FROM RowNumCTE
WHERE row_num > 1


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Select *
From PPT2..Nashville

ALTER TABLE PPT2..Nashville
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate, TaxDistrict






















