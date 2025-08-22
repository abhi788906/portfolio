const AWS = require('aws-sdk');

// Configure AWS SDK
const costExplorer = new AWS.CostExplorer();
const ce = new AWS.CostExplorer();

exports.handler = async (event) => {
    try {
        // Set CORS headers
        const headers = {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Methods': 'GET, POST, OPTIONS'
        };

        // Handle preflight requests
        if (event.httpMethod === 'OPTIONS') {
            return {
                statusCode: 200,
                headers,
                body: ''
            };
        }

        const today = new Date();
        const startOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);
        const startOfLastMonth = new Date(today.getFullYear(), today.getMonth() - 1, 1);
        const endOfLastMonth = new Date(today.getFullYear(), today.getMonth(), 0);

        // Get today's cost - filtered for portfolio website resources
        const todayParams = {
            TimePeriod: {
                Start: today.toISOString().split('T')[0],
                End: today.toISOString().split('T')[0]
            },
            Granularity: 'DAILY',
            Metrics: ['UnblendedCost'],
            GroupBy: [
                {
                    Type: 'DIMENSION',
                    Key: 'SERVICE'
                }
            ],
            Filter: {
                Tags: {
                    Key: 'Project',
                    Values: ['portfolio-website']
                }
            }
        };

        // Get this month's cost - filtered for portfolio website resources
        const thisMonthParams = {
            TimePeriod: {
                Start: startOfMonth.toISOString().split('T')[0],
                End: today.toISOString().split('T')[0]
            },
            Granularity: 'MONTHLY',
            Metrics: ['UnblendedCost'],
            Filter: {
                Tags: {
                    Key: 'Project',
                    Values: ['portfolio-website']
                }
            }
        };

        // Get last month's cost - filtered for portfolio website resources
        const lastMonthParams = {
            TimePeriod: {
                Start: startOfLastMonth.toISOString().split('T')[0],
                End: endOfLastMonth.toISOString().split('T')[0]
            },
            Granularity: 'MONTHLY',
            Metrics: ['UnblendedCost'],
            Filter: {
                Tags: {
                    Key: 'Project',
                    Values: ['portfolio-website']
                }
            }
        };

        // Fetch all cost data
        let todayData, thisMonthData, lastMonthData;
        
        try {
            // Try with tag filtering first
            [todayData, thisMonthData, lastMonthData] = await Promise.all([
                ce.getCostAndUsage(todayParams).promise(),
                ce.getCostAndUsage(thisMonthParams).promise(),
                ce.getCostAndUsage(lastMonthParams).promise()
            ]);
        } catch (error) {
            console.log('Tag filtering failed, trying resource-based filtering...');
            
            // Fallback: Filter by specific resource names for portfolio website only
            const resourceFilter = {
                Dimensions: {
                    Key: 'RESOURCE_ID',
                    Values: [
                        'abhishek-portfolio-website', // S3 bucket - TODO: Make this configurable
                        'E1B34WDBG65GFG', // CloudFront distribution ID - TODO: Make this configurable
                        'portfolio-billing-api' // Lambda function - TODO: Make this configurable
                    ]
                }
            };
            
            const fallbackTodayParams = { ...todayParams, Filter: resourceFilter };
            const fallbackThisMonthParams = { ...thisMonthParams, Filter: resourceFilter };
            const fallbackLastMonthParams = { ...lastMonthParams, Filter: resourceFilter };
            
            [todayData, thisMonthData, lastMonthData] = await Promise.all([
                ce.getCostAndUsage(fallbackTodayParams).promise(),
                ce.getCostAndUsage(fallbackThisMonthParams).promise(),
                ce.getCostAndUsage(fallbackLastMonthParams).promise()
            ]);
        }

        // Process today's data
        let dailyTotal = 0;
        let s3Cost = 0;
        let cloudfrontCost = 0;
        let lambdaCost = 0;
        let cloudflareCost = 0; // Cloudflare Free plan cost

        if (todayData.ResultsByTime && todayData.ResultsByTime[0] && todayData.ResultsByTime[0].Groups) {
            todayData.ResultsByTime[0].Groups.forEach(group => {
                const cost = parseFloat(group.Metrics.UnblendedCost.Amount);
                dailyTotal += cost;

                if (group.Keys[0].includes('S3')) {
                    s3Cost += cost;
                } else if (group.Keys[0].includes('CloudFront')) {
                    cloudfrontCost += cost;
                } else if (group.Keys[0].includes('Lambda')) {
                    lambdaCost += cost;
                }
            });
        }

        // Add Cloudflare Free plan cost (always $0)
        cloudflareCost = 0;
        dailyTotal += cloudflareCost;

        // Process monthly data
        const thisMonthTotal = thisMonthData.ResultsByTime && thisMonthData.ResultsByTime[0] 
            ? parseFloat(thisMonthData.ResultsByTime[0].Total.UnblendedCost.Amount) 
            : 0;

        const lastMonthTotal = lastMonthData.ResultsByTime && lastMonthData.ResultsByTime[0] 
            ? parseFloat(lastMonthData.ResultsByTime[0].Total.UnblendedCost.Amount) 
            : 0;

        const response = {
            daily: {
                total: dailyTotal,
                s3: s3Cost,
                cloudfront: cloudfrontCost,
                lambda: lambdaCost,
                cloudflare: cloudflareCost
            },
            monthly: {
                current: thisMonthTotal,
                previous: lastMonthTotal
            },
            lastUpdated: new Date().toISOString()
        };

        return {
            statusCode: 200,
            headers: {
                ...headers,
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(response)
        };

    } catch (error) {
        console.error('Error fetching AWS billing:', error);
        
        return {
            statusCode: 500,
            headers: {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                error: 'Failed to fetch billing data',
                message: error.message
            })
        };
    }
}; 