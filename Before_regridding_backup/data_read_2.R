
data_read <- function(period, model, dataset) {

#################################
    
    ## if (dataset == 'LGM') {
    ##     if (period == 'Holocene') {
    ##         data <- LGM_hol_prox_data }
    ##     else {
    ##         data <- LGM_lgm_prox_data }
        
    ##     df = data.frame(data)
        
    ##     df$Ocean_depth <- df$Dep
    ##     if (period == 'Holocene') {df$d13C <- df$d13C_hol} else(df$d13C <- df$d13C_lgm)

    ##     if (period == 'Holocene') {
    ##         if(model == 'UVic') {model_data <- UVic_hol_model_data} else(model_data <- LOVECLIM_hol_model_data)}
    ##     else {
    ##             ifelse(model == 'UVic', model_data <- UVic_lgm_model_data, model_data <- LOVECLIM_lgm_model_data)

    ##         }}

##################################

    if (dataset == 'LIG') {
        
        if (period == 'Holocene') {
            data <- LIG_hol_prox_data}
        else {
                data <- LIG_lig_prox_data}

        df = data.frame(data)

        if (period == 'Holocene') {
            if(model == 'UVic') {model_data <- UVic_hol_model_data} else(model_data <- LOVECLIM_hol_model_data)}
        else {
                ifelse(model == 'UVic', model_data <- UVic_lig_model_data, model_data <- LOVECLIM_lig_model_data)

            }}

#####################################
    model_data.o <<- model_data
    return(df)}
