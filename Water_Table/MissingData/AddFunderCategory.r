
addFunderCategory <- function(data) {
########### START::: shameless borrowed from https://nycdatascience.com/blog/student-works/linlin_cheng_proj_5/: 
#generate a new variable to categorize funders:
fun<-as.character(data$funder)

#
f_gov<-c('danida', 'A/co germany', 'belgian', 'british', 'england', 'german', 'germany',
         'china', 'egypt', 'European Union', 'finland', 'japan', 'france', 'greec',
         'netherlands', 'holland', 'holand', 'nethe', 'nethalan', 'netherla', 'netherlands',
         'iran', 'irish', 'islam','italy', 'U.S.A', 'usa', 'usaid', 'swiss', 'swedish','korea', 'niger'
) #'Jica',
NGO<-c('World Bank', 'Ngo', "Ngos", "Un","Un Habitat", "Un/wfp", "Undp", "Undp/aict", "Undp/ilo", "Unesco",                        
       "Unhcr", "Unhcr/government", "Unice", "Unice/ Cspd", "Unicef", "Unicef/ Csp", "Unicef/african Muslim Agency", 
       "Unicef/central", "Unicef/cspd", "Uniceg", "Unicet", "Unicrf", "Uniseg", "Unp/aict", "wwf", "wfp")
local_commu <- unique(c(agrep('commu', data$funder, value=TRUE), #includes commu for community, vill for village
                        agrep('vill', data$funder, value=TRUE)))
tanz_gov<- unique(c(agrep('Government of Tanzania', data$funder, value=TRUE), #includes commu for community, vill for village
                    agrep('wsdp', data$funder, value=TRUE)))               

unique(fun[agrep('wsdp', fun)])

data$funder = as.character(data$funder)

temp = data$funder

for (i in 1:length(NGO)){
  temp = replace(temp, 
                 agrep(NGO[i], temp),
                 'UN_agencies')
}

for (i in 1:length(f_gov)){
  temp = replace(temp, 
                 agrep(f_gov[i], temp),
                 'foreign_gov')
}

for (i in 1:length(local_commu)){
  temp = replace(temp, 
                 agrep(local_commu[i], temp), 
                 "local_community")
}


for (i in 1:length(tanz_gov)){
  temp = replace(temp, 
                 agrep(tanz_gov[i], temp), 
                 "Tanzania_Gov")
}


temp = replace(temp, 
               temp != "UN_agencies" & temp != 'foreign_gov' & temp != 'local_community' & temp != 'Tanzania_Gov',
               'other')

#table(data$label, data$funder_cat)
data$funder_cat<-temp
return(data)
########### END::: shameless borrowed from https://nycdatascience.com/blog/student-works/linlin_cheng_proj_5/: 
}

