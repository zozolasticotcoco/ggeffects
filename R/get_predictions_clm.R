#' @export
get_predictions.clm <- function(model,
                                data_grid = NULL,
                                terms = NULL,
                                ci_level = 0.95,
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
  se <- !is.null(ci_level) && !is.na(ci_level)

  # compute ci, two-ways
  if (!is.null(ci_level) && !is.na(ci_level)) {
    ci <- ci_level
  } else {
    ci <- 0.95
  }

  # prediction, with CI
  prdat <- stats::predict(
    model,
    newdata = data_grid,
    type = "prob",
    interval = se,
    level = ci,
    ...
  )

  # convert to data frame.
  prdat <- as.data.frame(prdat)

  # bind predictions to model frame
  data_grid <- cbind(prdat, data_grid)

  # get levels of response
  lv <- levels(insight::get_response(model, verbose = FALSE))

  # for proportional ordinal logistic regression (see ordinal::clm),
  # we have predicted values for each response category. Hence,
  # gather columns. Since we also have conf. int. for each response
  # category, we need to gather multiple columns at once

  if (isTRUE(se)) {
    # length of each variable block
    l <- seq_len(ncol(prdat) / 3)
    colnames(data_grid)[l] <- lv

    data_grid <- .multiple_gather(
      data_grid,
      names_to = "response.level",
      values_to = c("predicted", "conf.low", "conf.high"),
      columns = list(l, l + length(l), l + 2 * length(l))
    )
  } else {
    data_grid <- .gather(
      data_grid,
      names_to = "response.level",
      values_to = "predicted",
      colnames(prdat)
    )
    # No CI
    data_grid$conf.low <- NA
    data_grid$conf.high <- NA
  }

  data_grid
}
