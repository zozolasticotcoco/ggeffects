skip_on_cran()
skip_on_os(c("mac", "solaris"))
skip_if_not_installed("datawizard")
skip_if_not_installed("withr")

test_that("ggpredict, condition", {
  data(efc, package = "ggeffects")
  efc$e42dep <- datawizard::to_factor(efc$e42dep)
  fit <- lm(barthtot ~ c12hour + neg_c_7 + e42dep + c172code, data = efc)

  expect_s3_class(ggpredict(fit, "c172code"), "data.frame")
  expect_s3_class(ggpredict(fit, "c172code", condition = c(c12hour = 40)), "data.frame")
  expect_s3_class(ggpredict(fit, "c172code", condition = c(c12hour = 40, e42dep = "severely dependent")), "data.frame")
  expect_s3_class(ggpredict(fit, "c172code", condition = c(e42dep = "severely dependent")), "data.frame")

  dg <- data_grid(fit, "c172code", condition = c(c12hour = 40, e42dep = "severely dependent"))
  out1 <- ggpredict(fit, "c172code", condition = c(c12hour = 40, e42dep = "severely dependent"))
  out2 <- predict(fit, newdata = dg)
  expect_equal(out1$predicted, out2, tolerance = 1e-4, ignore_attr = TRUE)

  dg <- data_grid(fit, "c172code")
  out1 <- ggpredict(fit, "c172code")
  out2 <- predict(fit, newdata = dg)
  expect_equal(out1$predicted, out2, tolerance = 1e-4, ignore_attr = TRUE)

  skip_if_not_installed("emmeans")
  expect_s3_class(ggemmeans(fit, "c172code"), "data.frame")
  expect_s3_class(ggemmeans(fit, "c172code", condition = c(c12hour = 40)), "data.frame")
  expect_s3_class(ggemmeans(fit, "c172code", condition = c(c12hour = 40, e42dep = "severely dependent")), "data.frame")
  expect_s3_class(ggemmeans(fit, "c172code", condition = c(e42dep = "severely dependent")), "data.frame")
})


withr::with_environment(
  new.env(),
  test_that("ggpredict, condition, glm", {
    skip_if_not_installed("emmeans")

    data(efc, package = "ggeffects")
    efc$e42dep <- datawizard::to_factor(efc$e42dep)
    efc$neg_c_7d <- as.numeric(efc$neg_c_7 > median(efc$neg_c_7, na.rm = TRUE))
    d <- efc
    m1 <- glm(
      neg_c_7d ~ c12hour + e42dep + c161sex + c172code,
      data = d,
      family = binomial(link = "logit")
    )

    expect_s3_class(
      ggpredict(m1, "c12hour", condition = c(e42dep = "severely dependent"), verbose = FALSE),
      "data.frame"
    )
    expect_s3_class(
      ggpredict(m1, c("c12hour", "c161sex"), condition = c(e42dep = "severely dependent"), verbose = FALSE),
      "data.frame"
    )
    expect_s3_class(
      ggpredict(m1, c("c12hour", "c161sex", "c172code"), condition = c(e42dep = "severely dependent"), verbose = FALSE),
      "data.frame"
    )
    expect_s3_class(
      ggemmeans(m1, "c12hour", condition = c(e42dep = "severely dependent"), verbose = FALSE),
      "data.frame"
    )
    expect_s3_class(
      ggemmeans(m1, c("c12hour", "c161sex"), condition = c(e42dep = "severely dependent"), verbose = FALSE),
      "data.frame"
    )
    expect_s3_class(
      ggemmeans(m1, c("c12hour", "c161sex", "c172code"), condition = c(e42dep = "severely dependent"), verbose = FALSE),
      "data.frame"
    )

    out <- ggpredict(m1, "c172code", condition = c(e42dep = "severely dependent"), verbose = FALSE)
    expect_equal(out$predicted, c(0.60806, 0.64322, 0.67691), tolerance = 1e-3)
    out <- ggpredict(m1, "c172code", condition = c(e42dep = "independent"), verbose = FALSE)
    expect_equal(out$predicted, c(0.10815, 0.12351, 0.14071), tolerance = 1e-3)

    m2 <- glm(
      neg_c_7d ~ c12hour + e42dep + c161sex + c172code,
      data = d,
      family = binomial(link = "logit")
    )
    expect_s3_class(ggpredict(m2, "c12hour", condition = c(c172code = 1), verbose = FALSE), "data.frame")
    expect_s3_class(ggpredict(m2, c("c12hour", "c161sex"), condition = c(c172code = 2), verbose = FALSE), "data.frame")
  })
)


withr::with_environment(
  new.env(),
  test_that("ggpredict, condition-lmer", {
    skip_if_not_installed("lme4")

    data(efc, package = "ggeffects")
    efc$grp <- datawizard::to_factor(efc$e15relat)
    efc$e42dep <- datawizard::to_factor(efc$e42dep)
    d2 <- efc
    m3 <- lme4::lmer(
      neg_c_7 ~ c12hour + e42dep + c161sex + c172code + (1 | grp),
      data = d2
    )

    pr <- ggpredict(m3, "c12hour", interval = "prediction")
    expect_equal(pr$predicted[1], 8.962075, tolerance = 1e-3)
    expect_equal(pr$std.error[1], 3.601748, tolerance = 1e-3)

    pr <- ggpredict(m3, "c12hour", interval = "prediction", condition = c(c172code = 1))
    expect_equal(pr$predicted[1], 8.62045, tolerance = 1e-3)
    expect_equal(pr$std.error[1], 3.606084, tolerance = 1e-3)

    pr <- ggpredict(m3, "c12hour", interval = "prediction", condition = c(e42dep = "severely dependent"))
    expect_equal(pr$predicted[1], 12.83257, tolerance = 1e-3)
    expect_equal(pr$std.error[1], 3.601748, tolerance = 1e-3)

    pr <- ggpredict(m3, "c12hour", interval = "prediction", condition = c(e42dep = "severely dependent", c172code = 3))
    expect_equal(pr$predicted[1], 13.19621, tolerance = 1e-3)
    expect_equal(pr$std.error[1], 3.608459, tolerance = 1e-3)

    pr <- ggpredict(m3, "c12hour", interval = "prediction", condition = c(e42dep = "severely dependent", c172code = 3, grp = "sibling")) # nolint
    expect_equal(pr$predicted[1], 13.19621, tolerance = 1e-3)
    expect_equal(pr$std.error[1], 3.608459, tolerance = 1e-3)

    pr <- ggpredict(m3, "c12hour", interval = "prediction", condition = c(c172code = 3, grp = "sibling"))
    expect_equal(pr$predicted[1], 9.325714, tolerance = 1e-3)
    expect_equal(pr$std.error[1], 3.608459, tolerance = 1e-3)

    pr <- ggpredict(m3, "c12hour", interval = "prediction", condition = c(grp = "sibling"))
    expect_equal(pr$predicted[1], 8.962075, tolerance = 1e-3)
    expect_equal(pr$std.error[1], 3.601748, tolerance = 1e-3)
  })
)
