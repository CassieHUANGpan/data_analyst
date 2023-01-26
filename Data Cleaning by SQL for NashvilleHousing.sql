--Cleaning data in SQL queries
Use PortfolioProject
Select * from NashvilleHousing;

--Standardize date format


ALTER TABLE NashvilleHousing
Add SaleDateConvert DATE

UPDATE NashvilleHousing
SET SaleDateConvert = CONVERT(date,SaleDate)

select SaleDateConvert, SaleDate from NashvilleHousing 

select * from NashvilleHousing


--Populate Property address data

Update a
set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]

select * from NashvilleHousing
--where PropertyAddress is null


--Breaking out Address into seperated colomns (state, city, street)
Use PortfolioProject
Select * from NashvilleHousing;

--Using Substring, Charindex to split the address
Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as PA1,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as PA2
from NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertyAddressRoad Nvarchar(255)

UPDATE NashvilleHousing
SET PropertyAddressRoad=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
ADD PropertyAddressCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertyAddressCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

--Using Parsename to split column, need to replace ',' to '.'
Select REPLACE(OwnerAddress,',','.') from NashvilleHousing;

Select PARSENAME(REPLACE(OwnerAddress,',','.'),3) as OwnerRoad,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as OwnerCity,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as OwnerState
from NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD OwnerRoad Nvarchar(255),OwnerCity Nvarchar(255),OwnerState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerRoad = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select * from NashvilleHousing;

--Change Y and N to Yes and No in 'SoldAsVacant':
Select distinct SoldAsVacant from NashvilleHousing;

Select *,
CASE WHEN SoldAsVacant='N' then 'No'
     WHEN SoldAsVacant='Y' then 'Yes'
	 Else SoldAsVacant
END AS SoldAsV
from NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD SoldAsVacant2 Nvarchar(255)

UPDATE NashvilleHousing
SET SoldAsVacant2 = CASE 
     WHEN SoldAsVacant='N' then 'No'
     WHEN SoldAsVacant='Y' then 'Yes'
	 Else SoldAsVacant
END

select * from NashvilleHousing;
select distinct SoldAsVacant2 from NashvilleHousing;

--Remove duplicate:
select * from NashvilleHousing;

with CTE as(
Select *,ROW_NUMBER() over(
Partition by ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference
ORDER BY UniqueID) row_num
from NashvilleHousing)
DELETE from CTE
where row_num >1

with CTE as(
Select *,ROW_NUMBER() over(
Partition by ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference
ORDER BY UniqueID) row_num
from NashvilleHousing)
select * from CTE
where row_num >1

--delete unuseful column:
Select * from NashvilleHousing;

ALTER TABLE NashvilleHousing
DROP COLUMN LandUse,PropertyAddress,TaxDistrict,OwnerAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDateConverted

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

ALTER TABLE NashvilleHousing
DROP COLUMN SoldAsVacant