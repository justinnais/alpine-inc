module.exports = {
  clearMocks: true,
  collectCoverageFrom: ['models/*.js'],
  coverageDirectory: 'coverage/',
  coveragePathIgnorePatterns: ['/node_modules/'],
  coverageReporters: ['json', 'text', 'lcov'],
  reporters: ['default', 'jest-junit'],
  testEnvironment: 'node',
};
