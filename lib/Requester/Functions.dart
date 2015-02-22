part of Requester;

int getExponentialBackOffTime (int attempts, [int maxBackOffTime = null]) {
  if (attempts > 0) {
    int exponentialBackOff = 1 << (attempts - 1);
    return maxBackOffTime != null ? Math.min(maxBackOffTime, exponentialBackOff) : exponentialBackOff;
  }
  else {
    return 0;
  }
}