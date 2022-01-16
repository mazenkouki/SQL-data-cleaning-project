--cleaning data in SQL queries 
select*
from data_cleaning_project.dbo.Nashvillehousing

--Standardize Date Format
--First method sometimes doesn't work not sure why
select SaleDate , CONVERT(Date,SaleDate) 
from data_cleaning_project.dbo.Nashvillehousing


UPDATE Nashvillehousing
SET SaleDate = CONVERT(Date, SaleDate)

select SaleDate
from data_cleaning_project..Nashvillehousing
-- second method
ALTER TABLE Nashvillehousing
ADD newSaleDate DATE;

UPDATE Nashvillehousing
SET newSaleDate = CONVERT(Date, SaleDate)

select newSaleDate
from data_cleaning_project..Nashvillehousing



-- Populate Property Adress data

Select *
from data_cleaning_project..Nashvillehousing
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from data_cleaning_project..Nashvillehousing a
JOIN data_cleaning_project..Nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From data_cleaning_project..Nashvillehousing a
Join data_cleaning_project..Nashvillehousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

Select PropertyAddress
from data_cleaning_project..Nashvillehousing

-- Breaking out adress into individual columns (Adress, city, state)

Select PropertyAddress
from data_cleaning_project..Nashvillehousing

Select 
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Adress,
SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as state

from data_cleaning_project..Nashvillehousing

ALTER TABLE Nashvillehousing
ADD PropertySplitAdress nvarchar(255);
UPDATE Nashvillehousing
SET PropertySplitAdress  = SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE Nashvillehousing
ADD PropertySplitCity nvarchar(255);
UPDATE Nashvillehousing
SET PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

-- second method applied to owneraddress

Select OwnerAddress
from data_cleaning_project..Nashvillehousing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From data_cleaning_project..Nashvillehousing

ALTER TABLE Nashvillehousing
ADD OwnersplitAddress nvarchar(255);
UPDATE Nashvillehousing
SET OwnersplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Nashvillehousing
ADD Ownersplitcity nvarchar(255);
UPDATE Nashvillehousing
SET Ownersplitcity =PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Nashvillehousing
ADD Ownersplitstate nvarchar(255);
UPDATE Nashvillehousing
SET Ownersplitstate = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- change y and n to yes and no in "sold as vacant" field*
Select  DISTINCT (SoldAsVacant), count(SoldAsVacant)
from data_cleaning_project..Nashvillehousing
group by SoldAsVacant
order by 2


select SoldAsVacant , CASE WHEN SoldAsVacant = 'y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
From data_cleaning_project..Nashvillehousing

UPDATE Nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END


--Remove Duplicates

WITH RownumCTE as (
select*,
ROW_NUMBER() OVER (
PARTITION BY ParcelID , PropertyAddress, SalePrice, SaleDate, LegalReference 
ORDER BY UniqueID ) row_num

from data_cleaning_project..Nashvillehousing
)
DELETE 
FROM
RownumCTE
where row_num > 1

-- checking if duplicates are gone
WITH RownumCTE as (
select*,
ROW_NUMBER() OVER (
PARTITION BY ParcelID , PropertyAddress, SalePrice, SaleDate, LegalReference 
ORDER BY UniqueID ) row_num

from data_cleaning_project..Nashvillehousing
)
select*
FROM
RownumCTE
where row_num > 1


-- Delete unused Columns

select * 
From data_cleaning_project..Nashvillehousing

ALTER TABLE data_cleaning_project..Nashvillehousing
DROP COLUMN SaleDateConverted



