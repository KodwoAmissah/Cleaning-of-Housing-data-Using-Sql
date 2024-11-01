--view data
select * from housingprojecte..House
order by ParcelID

---convert date from datetime to date
Alter Table House
Alter column SaleDate date

---view data to confirm results
select * from housingprojecte..House
order by ParcelID

--we observed propertyAddress has missing values,let's view that
select UniqueID, ParcelID,PropertyAddress from housingprojecte..House
order by ParcelID


--After observing i realised that the property address with null has the same parcelid and different uniqueid's
---Therefore we will populate the null values with the address of those with the same parcelIds and to do this we will join the dataset on itself

--joining the dataset on itself
select  
* from housingprojecte..House as a
join housingprojecte..House  as b 
on a.ParcelID=b.ParcelId
and a.UniqueID<>b.UniqueID

--here we will populate the missing values 
select a.ParcelID,b.ParcelID,a.PropertyAddress,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from housingprojecte..House as a
join housingprojecte..House  as b 
on a.ParcelID=b.ParcelId
and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null

---we will make this changes in to the table 
Update a
set PropertyAddress= isnull(a.PropertyAddress,b.PropertyAddress)
from housingprojecte..House as a
join housingprojecte..House  as b 
on a.ParcelID=b.ParcelId
and a.UniqueID<>b.UniqueID
where a.PropertyAddress is null

---in the dataset we will split the property address into address and City
select PropertyAddress,
PARSENAME(Replace(PropertyAddress,',','.'),2),
PARSENAME(Replace(PropertyAddress,',','.'),1)
from housingprojecte..House

--Add column for the address and city
Alter table housingprojecte..House
Add SplitPropertyAddress nvarchar(255)

Alter table housingprojecte..House
Add SplitPropertyAddressCity nvarchar(255)

---we update these columns
Update housingprojecte..House
set SplitPropertyAddress=PARSENAME(Replace(PropertyAddress,',','.'),2)

Update housingprojecte..House
set SplitPropertyAddressCity=PARSENAME(Replace(PropertyAddress,',','.'),1)


--we split the Owner Address into address city and state
select OwnerAddress,
PARSENAME(replace(OwnerAddress,',','.'),3),
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from housingprojecte..House
order by ParcelID

--add column for the address city state
Alter table housingprojecte..House
add SplitOwnerAddress nvarchar(255)

Alter table housingprojecte..House
add SplitOwnerAddressCity nvarchar(255)

Alter table housingprojecte..House
add SplitOwnerAddressState nvarchar(255)


Update housingprojecte..House
set SplitOwnerAddress=PARSENAME(replace(OwnerAddress,',','.'),3)

Update housingprojecte..House
set SplitOwnerAddressCity=PARSENAME(replace(OwnerAddress,',','.'),2)

Update housingprojecte..House
set SplitOwnerAddressState=PARSENAME(replace(OwnerAddress,',','.'),1)

---i also realised the sold as vacant column had yes,no and y,no so we will change all the N to No and Y to Yes
select distinct(SoldAsVacant),count(SoldAsVacant)
from housingprojecte..House
Group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
Else SoldAsVacant
End
from housingprojecte..House


---update the soldasvacant 
update housingprojecte..House
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
when SoldAsVacant='N' then 'No'
Else SoldAsVacant
End

--remove duplicates
select *,
ROW_NUMBER()over (partition by ParcelId,PropertyAddress,SalePrice order by UniqueID) as row_mum
from dbo.nashme;

-- put duplicate query in a CTE to make removal of duplicates easier
with rows as 
(select *,
ROW_NUMBER()over (partition by ParcelId,PropertyAddress,SalePrice order by UniqueID) as row_mum
from dbo.nashme)
delete from rows 
where row_mum > 1
 
--Remove Columns we changed
Alter table housingprojecte..House
Drop column OwnerAddress,PropertyAddress
