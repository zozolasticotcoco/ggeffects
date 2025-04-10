.set_attributes_and_class <- function(data,
                                      model,
                                      t.title,
                                      x.title,
                                      y.title,
                                      l.title,
                                      legend.labels,
                                      x.axis.labels,
                                      model_info,
                                      constant.values = NULL,
                                      terms = NULL,
                                      original_terms = NULL,
                                      at_list = NULL,
                                      n.trials = NULL,
                                      prediction.interval = NULL,
                                      condition = NULL,
                                      ci_level = 0.95,
                                      type = NULL,
                                      untransformed_predictions = NULL,
                                      back_transform = FALSE,
                                      response_transform = NULL,
                                      original_model_frame = NULL,
                                      vcov_args = NULL,
                                      margin = NULL,
                                      latent = FALSE,
                                      latent_thresholds = NULL,
                                      bias_correction = FALSE,
                                      verbose = TRUE) {
  # check correct labels
  if (!is.null(x.axis.labels) && length(x.axis.labels) != length(stats::na.omit(unique(data$x)))) {
    x.axis.labels <- as.vector(sort(stats::na.omit(unique(data$x))))
  }

  rownames(data) <- NULL

  if (!is.null(at_list) && !is.null(terms)) {
    at_list <- at_list[names(at_list) %in% terms]
  }

  # add attributes
  attr(data, "title") <- t.title
  attr(data, "x.title") <- x.title
  attr(data, "y.title") <- y.title
  attr(data, "legend.title") <- l.title
  attr(data, "legend.labels") <- legend.labels
  attr(data, "x.axis.labels") <- x.axis.labels
  attr(data, "constant.values") <- constant.values
  attr(data, "terms") <- terms
  attr(data, "original.terms") <- original_terms
  attr(data, "at.list") <- at_list
  attr(data, "prediction.interval") <- prediction.interval
  attr(data, "condition") <- condition
  attr(data, "ci_level") <- ci_level
  attr(data, "type") <- type
  attr(data, "response.name") <- insight::find_response(model)
  attr(data, "back_transform") <- back_transform
  attr(data, "response_transform") <- response_transform
  attr(data, "untransformed_predictions") <- untransformed_predictions
  attr(data, "standard_error") <- data$std.error
  attr(data, "vcov") <- vcov_args
  attr(data, "margin") <- margin
  attr(data, "df") <- .get_df(model)

  # add offset term information
  off_term <- insight::find_offset(model)
  if (!is.null(off_term)) {
    attr(data, "offset") <- off_term
    attr(data, "offset_values") <- .safe(original_model_frame[[off_term]])
    off_transform <- .get_offset_transformation(model)
    if (!insight::is_empty_object(off_transform)) {
      attr(data, "offset_transform") <- off_transform
    }
  }

  # remember fit family
  if (!is.null(model_info)) {
    attr(data, "family") <- model_info$family
    attr(data, "link") <- model_info$link_function
    if (latent) {
      attr(data, "logistic") <- FALSE
    } else {
      attr(data, "logistic") <- as.character(as.numeric(model_info$is_binomial || model_info$is_ordinal || model_info$is_multinomial || identical(type, "zi_prob"))) # nolint
    }
    attr(data, "is.trial") <- ifelse(model_info$is_trial && inherits(model, "brmsfit"), "1", "0")
  }
  attr(data, "link_inverse") <- .link_inverse(model, bias_correction = bias_correction)
  attr(data, "link_function") <- insight::link_function(model)
  attr(data, "n.trials") <- n.trials
  attr(data, "latent_thresholds") <- latent_thresholds

  # and model-function
  attr(data, "fitfun") <- .get_model_function(model)

  # other
  attr(data, "verbose") <- isTRUE(verbose)

  # add class attribute
  class(data) <- c("ggeffects", class(data))

  data
}
