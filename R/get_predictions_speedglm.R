#' @export
get_predictions.speedglm <- function(model,
                                     data_grid = NULL,
                                     terms = NULL,
                                     ci_level,
                                     type = NULL,
                                     typical = NULL,
                                     vcov = NULL,
                                     vcov_args = NULL,
                                     condition = NULL,
                                     interval = "confidence",
                                     bias_correction = FALSE,
                                     link_inverse = insight::link_inverse(model),
                                     model_info = NULL,
                                     verbose = TRUE,
                                     ...) {
  # does user want standard errors?
  se <- !is.null(ci_level) && !is.na(ci_level) && is.null(vcov)

  prdat <- stats::predict(
    model,
    newdata = data_grid,
    type = "link",
    se.fit = se,
    ...
  )

  # copy predictions
  .generic_prediction_data(
    model,
    data_grid,
    link_inverse,
    prediction_data = prdat,
    se,
    ci_level,
    typical,
    terms,
    vcov,
    vcov_args,
    condition,
    interval
  )
}

#' @export
get_predictions.speedlm <- get_predictions.speedglm

#' @export
get_predictions.bigglm <- get_predictions.speedglm
