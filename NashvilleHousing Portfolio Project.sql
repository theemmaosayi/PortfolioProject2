select *
from PortfolioProject2.dbo.NashvilleHousing$

--STANDARDISE DATE FORMAT

select SaleDate, CONVERT(Date,SaleDate)
from PortfolioProject2.dbo.NashvilleHousing$


--this didn't work as the code wasn't running --Update NashvilleHousing$
--SET SaleDate = CONVERT(Date,SaleDate)
--After doing research, I found out this didn't work because UPDATE doesn't change data types, The table 
--is actually updating but the data type for the column SaleDate is still datetime. 
--To change the data type, the syntax is; 

ALTER TABLE NashvilleHousing$
ALTER COLUMN SaleDate DATE


--This also works;
--ALTER TABLE NashvilleHousing$
--Add SaleDateConverted Date;

--Update NashvilleHousing$
--SET SaleDateConverted = CONVERT(Date,SaleDate)
--NB:I renamed SaleDate to SaleDateConverted
----------------------------------------------------



--POPULATE PROPERTY ADDRESS DATA 

select * 
from PortfolioProject2.dbo.NashvilleHousing$
--WHERE PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from PortfolioProject2.dbo.NashvilleHousing$ a
JOIN PortfolioProject2.dbo.NashvilleHousing$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--replace NULL a.propertyaddress

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject2.dbo.NashvilleHousing$ a
JOIN PortfolioProject2.dbo.NashvilleHousing$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--UPDATE TABLE 

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject2.dbo.NashvilleHousing$ a
JOIN PortfolioProject2.dbo.NashvilleHousing$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



--Doublecheck if tabel updated successfully
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject2.dbo.NashvilleHousing$ a
JOIN PortfolioProject2.dbo.NashvilleHousing$ b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking Out Address Into Individual Columns (Address, City, State)


select PropertyAddress
from PortfolioProject2.dbo.NashvilleHousing$
--WHERE PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

from PortfolioProject2.dbo.NashvilleHousing$

--We can't separate 2 values from 1 column without creating 2 other columns

ALTER TABLE NashvilleHousing$
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing$
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing$
Add PropertySplitCity Nvarchar(255);


Update NashvilleHousing$
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


select *
from PortfolioProject2.dbo.NashvilleHousing$


select OwnerAddress
from PortfolioProject2.dbo.NashvilleHousing$


--Doing same thing on OwnerAddress but using PARSENAME instead 


select 
PARSENAME(OwnerAddress,1)
from PortfolioProject2.dbo.NashvilleHousing$


select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject2.dbo.NashvilleHousing$



ALTER TABLE NashvilleHousing$
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing$
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing$
Add OwnerSplitCity Nvarchar(255);


Update NashvilleHousing$
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing$
Add OwnerSplitState Nvarchar(255);


Update NashvilleHousing$
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


select *
from PortfolioProject2.dbo.NashvilleHousing$


--Change Y and N to Yes and No in "SoldAsVacant" field 


select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject2.dbo.NashvilleHousing$
Group by SoldAsVacant
Order by 2



select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'			
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from PortfolioProject2.dbo.NashvilleHousing$


Update NashvilleHousing$
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'			
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



--REMOVE DUPLICATES

WITH RowNumCTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

from PortfolioProject2.dbo.NashvilleHousing$
--order by ParcelID
)
Select *
from RowNumCTE
where row_num > 1
order by PropertyAddress





--DELETE UNUSED COLUMNS 



select *
from PortfolioProject2.dbo.NashvilleHousing$


ALTER TABLE PortfolioProject2.dbo.NashvilleHousing$
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


--ALTER TABLE PortfolioProject2.dbo.NashvilleHousing$
--DROP COLUMN SaleDate