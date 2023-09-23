/*
Take project
  For each contribution, take the square root of contribution
  Sum of square root contributions
  Square of the result
*/

const projects = [
  {
    name: 'Saving the Rainforest',
    contribs: [100, 100, 100, 100],
  },
  {
    name: 'Water for the Planet',
    contribs: [200, 200],
  },
  {
    name: 'Forest Firefighters',
    contribs: [400]
  },
  {
    name: 'Beach Cleanup',
    contribs: [800, 100, 100]
  }

];

const funding = 10000;

const run = (pjs, funding) => {
  for(p of pjs) {
    console.log(`Calculating the proportion for ${p.name}`);
    p.proportion = quadraticFundingForm(p.contribs);
    console.log(`>> ${p.proportion}`);
  }
  funds = funding;
  console.log(`Total Funding: ${funds}`);

  //Calculate funding distribution
  //Sum of proportions
  let pSum = pjs.reduce((a, c) => a + c.proportion, 0);

  for(p of pjs) {
    console.log(`Calculating the funding for ${p.name}`);
    p.funding = (funds * p.proportion)/pSum;
    console.log(`Funding: ${p.funding}`);
  }
}

const quadraticFunding = () => {};

const quadraticFundingForm = (contribs) => {
    let sum = 0;
    for(c of contribs) {
      sum += Math.sqrt(c);
    }
    return Math.pow(sum, 2);
}

run(projects, funding);

export { run, quadraticFundingForm };

