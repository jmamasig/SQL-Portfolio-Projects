SELECT *
FROM Portfolio..NashvilleHousing


-- Standardize Date Format
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM Portfolio..NashvilleHousing

UPDATE Portfolio..NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE Portfolio..NashvilleHousing
ADD SaleDateConversion Date;

UPDATE Portfolio..NashvilleHousing
SET SaleDateConversion = CONVERT(Date, SaleDate)

SELECT SaleDateConversion, CONVERT(Date, SaleDate)
FROM Portfolio..NashvilleHousing


-- Populate Property Address Data
SELECT *
FROM Portfolio..NashvilleHousing
WHERE PropertyAddress is NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio..NashvilleHousing a
JOIN Portfolio..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


-- Dividing Property Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM Portfolio..NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM Portfolio..NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


SELECT *
FROM Portfolio..NashvilleHousing


-- Dividing Owner Address into Individual Columns (Address, City, State)
SELECT OwnerAddress
FROM Portfolio..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Portfolio..NashvilleHousing


ALTER TABLE Portfolio..NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update Portfolio..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Portfolio..NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update Portfolio..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Portfolio..NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update Portfolio..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM Portfolio..NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" Field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Portfolio..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Portfolio..NashvilleHousing


UPDATE Portfolio..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


-- Remove Duplicates
WITH RowNumCTE AS(
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

FROM Portfolio..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1


WITH RowNumCTE AS(
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

FROM Portfolio..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Delete Unused Columns
SELECT *
FROM Portfolio..NashvilleHousing


ALTER TABLE Portfolio..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate

