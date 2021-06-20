/* Cleaning Data in SQL */


SELECT * 
FROM PortfolioProject.dbo.NashvilleHousing

--1.
--Standardize Date Format
SELECT SaleDateConverted, Convert(Date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

USE PortfolioProject
UPDATE NashvilleHousing
SET SaleDate =  Convert(Date, SaleDate)

--USE PortfolioProject
--ALTER TABLE NashvilleHousing
--Add SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted =  Convert(Date, SaleDate)

---------------------------------------------------------------------------------------------------------
--2.
--Populate Property address data
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID] <> b.[UniqueID]
	WHERE a.PropertyAddress IS NULL

---------------------------------------------------------------------------------------
--3.
--Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.NashvilleHousing


USE PortfolioProject
ALTER TABLE NashvilleHousing
Add PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress =  SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress));

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;


----------------------------------------------------------------------------------------
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing;

--Using Parsename
SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.dbo.NashvilleHousing;




USE PortfolioProject

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress,',','.'),2);


ALTER TABLE NashvilleHousing
Add OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress,',','.'),1)


SELECT *
FROM PortfolioProject.dbo.NashvilleHousing;

-----------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field
SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2;


--Using CASE statement
SELECT SoldasVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
  END
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
					WHEN SoldAsVacant = 'N' THEN 'No'
					ELSE SoldAsVacant
					END

--Remove Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num

FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

---------------------------------------------------------------------------------
--Delete Unused Columns

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate