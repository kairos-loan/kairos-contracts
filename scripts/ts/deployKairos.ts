import { deployKairos } from "./deployFunc"

deployKairos().catch((error) => {
  console.error(error)
  process.exitCode = 1
})
