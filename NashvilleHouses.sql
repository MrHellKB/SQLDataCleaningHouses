
---------------------------------------------------------- DATA CLEANING SQL ----------------------------------------------------------

SELECT *
FROM NashvilleHouses

--- STANDART TIME

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM NashvilleHouses

UPDATE NashvilleHouses
SET Saledate = CONVERT(Date,SaleDate)

--------------------------------------

ALTER TABLE NashvilleHouses
ADD SaleDateConverted Date;

UPDATE NashvilleHouses
SET SaleDateConverted = CONVERT(Date,SaleDate)

--- POPOULATE PROPERTY ADDRESS DATA

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress )
FROM NashvilleHouses A
JOIN NashvilleHouses B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress )
FROM NashvilleHouses A
JOIN NashvilleHouses B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

SELECT PropertyAddress
FROM NashvilleHouses
WHERE PropertyAddress IS NULL

--- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
FROM NashvilleHouses

-- PROPERTY ADRESS SPLIT

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM NashvilleHouses

ALTER TABLE NashvilleHouses
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHouses
SET PropertySplitAddress =SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHouses
ADD City Nvarchar(255);

UPDATE NashvilleHouses
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

-- OWNER ADRESS SPLIT

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHouses

ALTER TABLE NashvilleHouses
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHouses
SET OwnerSplitAddress =PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHouses
ADD OwnerCity Nvarchar(255);

UPDATE NashvilleHouses
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHouses
ADD OwnerState Nvarchar(255);

UPDATE NashvilleHouses
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--- CHANGE Y AND N TO YES AND NO IN "SOLD AS VACANT" FIELD

SELECT DISTINCT SoldAsVacant
FROM NashvilleHouses

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
FROM NashvilleHouses

UPDATE NashvilleHouses
SET SoldAsVacant =
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END

--- REMOVE DUPLICATES

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 Saleprice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
FROM NashvilleHouses)

DELETE 
FROM RowNumCTE
WHERE row_num > 1

--- DELETE UNUSED COLUMNS

SELECT *
FROM NashvilleHouses

ALTER TABLE NashvilleHouses
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




