
--Cleaning data

select *
from Nashville

--Standarize date format

select SaleDate, CONVERT(date, SaleDate)
from Nashville

--add new column

alter table nashville
add saleDateConverted date

--update values in the new column

update Nashville
set saleDateConverted = convert(date,SaleDate)

-------------------------------------------------------------

--Populate property address data
--View rows with null value in PropertyAddress column

select *
from Nashville
where PropertyAddress is null

--One way to deal with null values is to remove them, before proceeding let's check if there is a way to complete them.
--Check if all equal ParcelID have the same PropertyAddress

select a.UniqueID, b.UniqueID, a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from Nashville a
join Nashville b
	on a.ParcelID = b.ParcelID
	and a.UniqueID != b.UniqueID
--and, add the where clause
where a.PropertyAddress is null

--update to complete all null values in the PropertyAddress column

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from nashville a
join nashville b
	on a.parcelid = b.parcelid
	and a.uniqueid != b.uniqueid
where a.propertyaddress is null

------------------------------------------------------------------------

--Breaking out propertyAddress into individual columns (Address, city, state)

select PropertyAddress
from Nashville

--query that returns the address in individual columns

select SUBSTRING(propertyaddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(propertyaddress) ) as City
from Nashville

--add two new columns

alter table nashville
add Address nvarchar(255), 
	City nvarchar(255)

--update values in the two new columns

update Nashville
set Address = SUBSTRING(propertyaddress, 1, CHARINDEX(',',PropertyAddress) -1),
	City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(propertyaddress))

--Breaking out OwnerAddress into individual columns

select OwnerAddress
from Nashville

select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from Nashville

--add three new columns

alter table nashville
add ownerAdd nvarchar(250),
	ownerCity nvarchar(250),
	ownerState nvarchar(250)

--update values in the three new columns

update Nashville
set ownerAdd = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	ownerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	ownerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--------------------------------------------------------------------------

--change Y ans N to Yes and No in 'sold as vacant' field

select distinct(SoldAsVacant)
from Nashville


select SoldAsVacant, 
case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end
from Nashville


update Nashville
set SoldAsVacant = case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
	end

------------------------------------------------------------------

--Remove dupplicates

with rownumCTE as(
select *,
	ROW_NUMBER() over(
	partition by parcelid,
				propertyaddress,
				saleprice,
				saledate,
				legalreference
				order by uniqueid
				) row_num
from Nashville
)
select *
from rownumCTE
where row_num > 1

delete
from rownumCTE
where row_num > 1
--------------------------------------------------------------

--delete unused columns

select * 
from Nashville

alter table nashville
drop column owneraddress, taxdistrict, propertyaddress, saledate
