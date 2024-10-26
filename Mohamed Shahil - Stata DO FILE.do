* Transforming revenue and price into natural logarithms
gen log_revenue = log(revenue)
gen log_price = log(price + 0.1)


* Encoding categorical variables into numerical formats
encode monetization_strategies, gen(mon_strategy_num)
encode main_category, gen(category_num)


* Conducting a summary statistical analysis
summarize


* Generating a correlation matrix for selected variables
corr log_revenue rating log_price  num_langs size


* Creating a flag for identifying gaming apps
gen flag_is_gaming = main_category == "Games"


*Labelling Variables
label variable product_id " product_id "
label variable name " name "
label variable developer " developer "
label variable version " version "
label variable release_date "release_date"
label variable devices "devices"
label variable active "active"
label variable price "price"
label variable is_paid "is_paid"
label variable size "size"
label variable rating "rating"


* Generate summary statistics for the full sample, gaming and non-gaming apps
*Create a new variable 'sample_type' to distinguish between gaming , non-gaming apps and full sample
gen sample_category = "Full Sample" if main_category != ""
replace sample_category = "Gaming Apps" if flag_is_gaming
replace sample_category = "Non-Gaming Apps" if !flag_is_gaming & main_category != ""
 
 
tabstat log_revenue log_price rating num_langs size , statistics(count mean min max sd) by(sample_category) columns(statistics)


* Anova for Difference in Logged Revenue gaming and non-gaming apps
anova log_revenue category_num


* Conducting a T-test for revenue differences between gaming and non-gaming apps
ttest log_revenue, by(flag_is_gaming)


* Creating a histogram for logged revenue with adjusted color
histogram log_revenue, color(green) title("Histogram of Logged Revenue") xlabel(,grid) ylabel(,grid)
histogram log_price, color(green) title("Histogram of Logged Price") xlabel(,grid) ylabel(,grid)




* Generating a box plot for logged revenue with a new color scheme
graph box log_revenue,title("Box Plot of Logged Revenue")


* Scatter plot to analyze logged revenue vs. rating
scatter log_revenue rating, title("Logged Revenue vs. Rating") ylabel(,grid) xlabel(,grid) 


* Scatter plot to examine logged revenue vs. logged price
scatter log_revenue log_price, title("Logged Revenue vs. Logged Price") ylabel(,grid) xlabel(,grid) 


* Scatter plot to examine Logged Revenue vs. Number of Languages
scatter log_revenue num_langs, title("Logged Revenue vs. Number of Languages") ylabel(,grid) xlabel(,grid) 



* Encoding age target for regression analysis
encode age_target, gen(age_target_cat)


 //ROBUST
* Run the baseline model
reg log_revenue rating log_price i.age_target_cat i.mon_strategy_num num_langs i.category_num
eststo m1

///baseline model to use///


//Part 1
margins mon_strategy_num
marginsplot


  //Part 2
margins age_target_cat
marginsplot
 
 
 
//2
* Run the modified OLS regression with interaction terms
regress log_revenue rating log_price  i.mon_strategy_num##c.rating i.age_target_cat num_langs i.category_num
eststo m2
 
 
margins mon_strategy_num
marginsplot

 
predict fitted
predict resid, residual
twoway (scatter resid  fitted), yline(0)


 *white test
imtest, white


*run the baseline model with robust standard errors
regress log_revenue rating log_price i.mon_strategy_num i.age_target_cat num_langs i.category_num, vce (robust)
eststo m3


 
* Predict the values of ln_revenue using the model
* Create a scatter plot of actual ln_revenue vs. ln_price and overlay the predicted values
* Prepare the variables
gen log_price_sq = log_price^2
 
 
 
* Run the regression with the quadratic term
regress log_revenue rating log_price log_price_sq i.mon_strategy_num i.age_target_cat num_langs i.category_num
eststo m4

twoway (scatter log_revenue log_price) (lowess log_revenue log_price )
twoway (qfit log_revenue log_price )



*Installing Package
ssc install estout, replace
set more off

eststo clear

*exporting Correlation matrix  
corr log_revenue log_price rating num_langs size
estpost corr ln_revenue ln_price rating num_langs size, matrix listwise
eststo c2
esttab c2 using corr_table2.rtf, replace label unstack not

*exporting regression results of baseline model & OLS regression with interaction terms
esttab m1 m2 using regression1_table.rtf, replace ar2(3) b(3) se(3) r2(3) label compress

*exporting regression results of baseline model with robust standard errors & regression with the quadratic term
esttab m3 m4 using regression4_table.rtf, replace ar2(3) b(3) se(3) r2(3) label compress


