/*
Data Cleaning in SQL using SQL Server
*/

Select *
From nashville_housing


--Standardizing Date Format

Select saledate, Convert(date,SaleDate) AS saledate_converted
From nashville_housing

ALTER TABLE Nashville_Housing
Add SaleDate_convert Date;

UPDATE nashville_housing
Set SaleDate_convert = Convert(date,saledate)

ALTER TABLE nashville_housing
DROP COLUMN SaleDate


-- Populating Property address column

Select * from nashville_housing
Order By ParcelID

--We can see that there are null values in some instances in PropertyAddress
--We can also see that if the ParcelID of two observations are the same then the property address is also the same

Select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) as PropertyAddressNew
From nashville_housing a
Join nashville_housing b
ON a.parcelID = b.parcelID
AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null 

UPDATE a
SET a.propertyaddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From nashville_housing a
Join nashville_housing b
ON a.parcelID = b.parcelID
AND a.[UniqueID ] <> b.[UniqueID ]


-- Dividing address into individual columns (Address, City, State)

Select PropertyAddress
From nashville_housing

Select PARSENAME(Replace(PropertyAddress, ',', '.'),2),
PARSENAME(Replace(PropertyAddress, ',', '.'),1)
FROM nashville_housing

ALTER TABLE nashville_housing
Add PropertySplitAddress Nvarchar(255)

Update nashville_housing
SET PropertySplitAddress = PARSENAME(REPLACE(PropertyAddress, ',', '.') , 2)

ALTER TABLE nashville_housing
Add PropertySplitCity Nvarchar(255)

Update nashville_housing
SET PropertySplitCity = PARSENAME(REPLACE(PropertyAddress, ',', '.') , 1)

Select *
From nashville_housing


Select OwnerAddress
From nashville_housing

ALTER TABLE nashville_housing
Add OwnerSplitAddress Nvarchar(255)

Update nashville_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE nashville_housing
Add OwnerSplitCity Nvarchar(255)

Update nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE nashville_housing
Add OwnerSplitState Nvarchar(255)

Update nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From nashville_housing


-- Changing Y and N to Yes and No in the "Sold as Vacant" column

Select Distinct(SoldAsVacant), Count(SoldAsVacant) 
From nashville_housing
Group by SoldAsVacant
order by Count(SoldAsVacant)

Select SoldAsVacant,	
	Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	End
From nashville_housing


UPDATE nashville_housing
SET SoldAsVacant =		Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else soldAsVacant
	End


-- Removing Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate_convert,
				 LegalReference
				 ORDER BY
					UniqueID
					) as row_num

From nashville_housing
)

Delete
From RowNumCTE
Where row_num > 1


Select*
From nashville_housing


-- Delete Unnecessary Columns

Select *
From nashville_housing


ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
