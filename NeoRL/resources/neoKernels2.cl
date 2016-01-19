// ----------------------------------------- Samplers -----------------------------------------

constant sampler_t normalizedClampedNearestSampler = CLK_NORMALIZED_COORDS_TRUE |
	CLK_ADDRESS_CLAMP |
	CLK_FILTER_NEAREST;

constant sampler_t normalizedClampedToEdgeNearestSampler = CLK_NORMALIZED_COORDS_TRUE |
	CLK_ADDRESS_CLAMP_TO_EDGE |
	CLK_FILTER_NEAREST;

constant sampler_t unnormalizedClampedNearestSampler = CLK_NORMALIZED_COORDS_FALSE |
	CLK_ADDRESS_CLAMP |
	CLK_FILTER_NEAREST;

constant sampler_t defaultNormalizedSampler = CLK_NORMALIZED_COORDS_TRUE |
	CLK_ADDRESS_CLAMP_TO_EDGE |
	CLK_FILTER_NEAREST;

constant sampler_t defaultUnnormalizedSampler = CLK_NORMALIZED_COORDS_FALSE |
	CLK_ADDRESS_CLAMP_TO_EDGE |
	CLK_FILTER_NEAREST;

// ----------------------------------------- Common -----------------------------------------

float randFloat(uint2* state) {
	const float invMaxInt = 1.0f / 4294967296.0f;
	uint x = (*state).x * 17 + (*state).y * 13123;
	(*state).x = (x << 13) ^ x;
	(*state).y ^= (x << 7);

	uint tmp = x * (x * x * 15731 + 74323) + 871483;

	return convert_float(tmp) * invMaxInt;
}

float randNormal(uint2* state) {
	float u1 = randFloat(state);
	float u2 = randFloat(state);

	return sqrt(-2.0f * log(u1)) * cos(6.28318f * u2);
}

float sigmoid(float x) {
	return 1.0f / (1.0f + exp(-x));
}

bool inBounds0(int2 position, int2 upperBound) {
	return position.x >= 0 && position.x < upperBound.x && position.y >= 0 && position.y < upperBound.y;
}

bool inBounds(int2 position, int2 lowerBound, int2 upperBound) {
	return position.x >= lowerBound.x && position.x < upperBound.x && position.y >= lowerBound.y && position.y < upperBound.y;
}

// Initialize a random uniform 2D image (X field)
void kernel randomUniform2D(write_only image2d_t values, uint2 seed, float2 minMax) {
	uint2 seedValue = seed + (uint2)(get_global_id(0) * 29 + 12, get_global_id(1) * 16 + 23) * 36;

	int2 position = (int2)(get_global_id(0), get_global_id(1));

	float value = randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x;

	write_imagef(values, position, (float4)(value, 0.0f, 0.0f, 0.0f));
}

// Initialize a random uniform 3D image (X field)
void kernel randomUniform3D(write_only image3d_t values, uint2 seed, float2 minMax) {
	uint2 seedValue = seed + (uint2)(get_global_id(0) * 12 + 76 + get_global_id(2) * 3, get_global_id(1) * 21 + 42 + get_global_id(2) * 7) * 12;

	int3 position = (int3)(get_global_id(0), get_global_id(1), get_global_id(2));

	float value = randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x;

	write_imagef(values, (int4)(position, 0), (float4)(value, 0.0f, 0.0f, 0.0f));
}

// Initialize a random uniform 2D image (XY fields)
void kernel randomUniform2DXY(write_only image2d_t values, uint2 seed, float2 minMax) {
	uint2 seedValue = seed + (uint2)(get_global_id(0) * 15 + 66, get_global_id(1) * 61 + 2) * 56;

	int2 position = (int2)(get_global_id(0), get_global_id(1));

	float2 v = (float2)(randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x, randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x);

	write_imagef(values, position, (float4)(v.x, v.y, 0.0f, 0.0f));
}

// Initialize a random uniform 2D image (XYZ fields)
void kernel randomUniform2DXYZ(write_only image2d_t values, uint2 seed, float2 minMax) {
	uint2 seedValue = seed + (uint2)(get_global_id(0) * 15 + 66, get_global_id(1) * 61 + 2) * 56;

	int2 position = (int2)(get_global_id(0), get_global_id(1));

	float3 v = (float3)(randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x, randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x, randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x);

	write_imagef(values, position, (float4)(v.x, v.y, v.z, 0.0f));
}

// Initialize a random uniform 2D image (XZ fields)
void kernel randomUniform2DXZ(write_only image2d_t values, uint2 seed, float2 minMax) {
	uint2 seedValue = seed + (uint2)(get_global_id(0) * 29 + 12, get_global_id(1) * 16 + 23) * 36;

	int2 position = (int2)(get_global_id(0), get_global_id(1));

	float2 v = (float2)(randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x, randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x);

	write_imagef(values, position, (float4)(v.x, 0.0f, v.y, 0.0f));
}

// Initialize a random uniform 3D image (XY fields)
void kernel randomUniform3DXY(write_only image3d_t values, uint2 seed, float2 minMax) {
	uint2 seedValue = seed + (uint2)(get_global_id(0) * 12 + 76 + get_global_id(2) * 3, get_global_id(1) * 21 + 42 + get_global_id(2) * 7) * 12;

	int3 position = (int3)(get_global_id(0), get_global_id(1), get_global_id(2));

	float2 v = (float2)(randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x, randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x);

	write_imagef(values, (int4)(position, 0), (float4)(v.x, v.y, 0.0f, 0.0f));
}

// Initialize a random uniform 3D image (XZ fields)
void kernel randomUniform3DXZ(write_only image3d_t values, uint2 seed, float2 minMax) {
	uint2 seedValue = seed + (uint2)(get_global_id(0) * 12 + 76 + get_global_id(2) * 3, get_global_id(1) * 21 + 42 + get_global_id(2) * 7) * 12;

	int3 position = (int3)(get_global_id(0), get_global_id(1), get_global_id(2));

	float2 v = (float2)(randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x, randFloat(&seedValue) * (minMax.y - minMax.x) + minMax.x);

	write_imagef(values, (int4)(position, 0), (float4)(v.x, 0.0f, v.y, 0.0f));
}

// ----------------------------------------- Sparse Predictor -----------------------------------------

void kernel spEncode(read_only image2d_t visibleStates,
	read_only image2d_t hiddenSummationTempBack, write_only image2d_t hiddenSummationTempFront, read_only image3d_t weights,
	int2 visibleSize, float2 hiddenToVisible, int radius)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);
	
	float sum = read_imagef(hiddenSummationTempBack, hiddenPosition).x;

	int2 fieldLowerBound = visiblePositionCenter - (int2)(radius);

	float subSum = 0.0f;

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);

			if (inBounds0(visiblePosition, visibleSize)) {
				int2 offset = visiblePosition - fieldLowerBound;

				int wi = offset.y + offset.x * (radius * 2 + 1);

				float weight = read_imagef(weights, (int4)(hiddenPosition.x, hiddenPosition.y, wi, 0)).x;

				float state = read_imagef(visibleStates, visiblePosition).x;

				subSum += state * weight;
			}
		}

	write_imagef(hiddenSummationTempFront, hiddenPosition, (float4)(sum + subSum));
}

void kernel spDecode(read_only image2d_t hiddenStates, read_only image2d_t feedBackStates,
	write_only image2d_t predictions, read_only image3d_t predWeights, read_only image3d_t feedBackWeights,
	int2 hiddenSize, int2 feedBackSize, float2 visibleToHidden, float2 visibleToFeedBack, int predRadius, int feedBackRadius, bool predBinary)
{
	int2 visiblePosition = (int2)(get_global_id(0), get_global_id(1));
	int2 hiddenPositionCenter = (int2)(visiblePosition.x * visibleToHidden.x + 0.5f, visiblePosition.y * visibleToHidden.y + 0.5f);
	int2 feedBackPositionCenter = (int2)(visiblePosition.x * visibleToFeedBack.x + 0.5f, visiblePosition.y * visibleToFeedBack.y + 0.5f);
	
	int2 hiddenFieldLowerBound = hiddenPositionCenter - (int2)(predRadius);
	int2 feedBackFieldLowerBound = feedBackPositionCenter - (int2)(feedBackRadius);

	float sum = 0.0f;

	for (int dx = -predRadius; dx <= predRadius; dx++)
		for (int dy = -predRadius; dy <= predRadius; dy++) {
			int2 hiddenPosition = hiddenPositionCenter + (int2)(dx, dy);

			if (inBounds0(hiddenPosition, hiddenSize)) {
				int2 offset = hiddenPosition - hiddenFieldLowerBound;

				int wi = offset.y + offset.x * (predRadius * 2 + 1);

				float weight = read_imagef(predWeights, (int4)(visiblePosition.x, visiblePosition.y, wi, 0)).x;

				float state = read_imagef(hiddenStates, hiddenPosition).x;

				sum += state * weight;
			}
		}

	for (int dx = -feedBackRadius; dx <= feedBackRadius; dx++)
		for (int dy = -feedBackRadius; dy <= feedBackRadius; dy++) {
			int2 feedBackPosition = feedBackPositionCenter + (int2)(dx, dy);

			if (inBounds0(feedBackPosition, feedBackSize)) {
				int2 offset = feedBackPosition - feedBackFieldLowerBound;

				int wi = offset.y + offset.x * (feedBackRadius * 2 + 1);

				float weight = read_imagef(feedBackWeights, (int4)(visiblePosition.x, visiblePosition.y, wi, 0)).x;

				float state = read_imagef(feedBackStates, hiddenPosition).x;

				sum += state * weight;
			}
		}

	write_imagef(predictions, visiblePosition, (float4)(predBinary ? (sum > 0.5f ? 1.0f : 0.0f) : sum));
}

void kernel spSolveHidden(read_only image2d_t hiddenSummationTemp,
	write_only image2d_t hiddenStatesFront,
	int2 hiddenSize, int radius, float activeRatio)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	
	float activation = read_imagef(hiddenSummationTemp, hiddenPosition).x;

	float inhibition = 0.0f;

	float counter = 0.0f;

	for (int dx = -radius; dx <= radius; dx++)
		for (int dy = -radius; dy <= radius; dy++) {
			if (dx == 0 && dy == 0)
				continue;
			
			int2 otherPosition = hiddenPosition + (int2)(dx, dy);

			if (inBounds0(otherPosition, hiddenSize)) {
				float otherActivation = read_imagef(hiddenSummationTemp, otherPosition).x;

				inhibition += otherActivation >= activation ? 1.0f : 0.0f;

				counter++;
			}
		}

	float state = inhibition < (counter * activeRatio) ? 1.0f : 0.0f;

	write_imagef(hiddenStatesFront, hiddenPosition, (float4)(state));
}

void kernel spPredictionError(read_only image2d_t predictionsPrev, read_only image2d_t visibleStates, read_only image2d_t additionalErrors,
	write_only image2d_t errors)
{
	int2 visiblePosition = (int2)(get_global_id(0), get_global_id(1));

	float predPrev = read_imagef(predictionsPrev, visiblePosition).x;
	float visibleState = read_imagef(visibleStates, visiblePosition).x;

	float predError = visibleState - predPrev;

	float additionalError = read_imagef(additionalErrors, visiblePosition).x;

	write_imagef(errors, visiblePosition, (float4)(predError + additionalError));
}

void kernel scErrorPropagation(read_only image2d_t errors,
	read_only image2d_t hiddenErrorSummationTempBack, write_only image2d_t hiddenErrorSummationTempFront,
	read_only image3d_t predWeights,
	int2 visibleSize, int2 hiddenSize, float2 visibleToHidden, float2 hiddenToVisible, int predRadius, int2 reversePredDecodeRadii)
{
	int2 hiddenPosition = (int2)(get_global_id(0), get_global_id(1));
	int2 visiblePositionCenter = (int2)(hiddenPosition.x * hiddenToVisible.x + 0.5f, hiddenPosition.y * hiddenToVisible.y + 0.5f);
	
	float error = read_imagef(hiddenErrorSummationTempFront, visiblePosition).x;

	for (int dx = -reversePredDecodeRadii.x; dx <= reversePredDecodeRadii.x; dx++)
		for (int dy = -reversePredDecodeRadii.y; dy <= reversePredDecodeRadii.y; dy++) {
			int2 visiblePosition = visiblePositionCenter + (int2)(dx, dy);
		
			if (inBounds0(visiblePosition, visibleSize)) {
				// Next layer node's receptive field
				int2 fieldCenter = (int2)(visiblePosition.x * visibleToHidden.x + 0.5f, visiblePosition.y * visibleToHidden.y + 0.5f);

				int2 fieldLowerBound = fieldCenter - (int2)(predRadius);
				int2 fieldUpperBound = fieldCenter + (int2)(predRadius + 1); // So is included in inBounds
		
				// Check for containment
				if (inBounds(hiddenPosition, fieldLowerBound, fieldUpperBound)) {	
					int2 offset = hiddenPosition - fieldLowerBound;

					float visibleError = read_imagef(errors, visiblePosition).x;

					int wi = offset.y + offset.x * (predRadius * 2 + 1);

					float weight = read_imagef(predWeights, (int4)(visiblePosition.x, visiblePosition.y, wi, 0)).x;
				
					error += visibleError * weight;
				}
			}
		}

	write_imagef(reconstructionError, visiblePosition, (float4)(error));
}

void kernel spLearnDecoderWeights(read_only image2d_t errors, read_only image2d_t hiddenStatesPrev, read_only image2d_t feedBackStatesPrev,
	read_only image3d_t predWeightsBack, write_only image3d_t predWeightsFront,
	read_only image3d_t feedBackWeightsBack, write_only image3d_t feedBackWeightsFront,
	int2 hiddenSize, int2 feedBackSize, float2 visibleToHidden, float2 visibleToFeedBack, int predRadius, int feedBackRadius, float weightAlpha)
{
	int2 visiblePosition = (int2)(get_global_id(0), get_global_id(1));
	int2 hiddenPositionCenter = (int2)(visiblePosition.x * visibleToHidden.x + 0.5f, visiblePosition.y * visibleToHidden.y + 0.5f);
	int2 feedBackPositionCenter = (int2)(visiblePosition.x * visibleToFeedBack.x + 0.5f, visiblePosition.y * visibleToFeedBack.y + 0.5f);
	
	int2 hiddenFieldLowerBound = hiddenPositionCenter - (int2)(predRadius);
	int2 feedBackFieldLowerBound = feedBackPositionCenter - (int2)(feedBackRadius);

	float error = read_imagef(errors, visiblePosition).x;

	for (int dx = -predRadius; dx <= predRadius; dx++)
		for (int dy = -predRadius; dy <= predRadius; dy++) {
			int2 hiddenPosition = hiddenPositionCenter + (int2)(dx, dy);

			if (inBounds0(hiddenPosition, hiddenSize)) {
				int2 offset = hiddenPosition - hiddenFieldLowerBound;

				int wi = offset.y + offset.x * (predRadius * 2 + 1);

				float weightPrev = read_imagef(predWeightsBack, (int4)(visiblePosition.x, visiblePosition.y, wi, 0)).x;

				float statePrev = read_imagef(hiddenStatesPrev, hiddenPosition).x;

				float weight = weightPrev + weightAlpha * error * statePrev;

				write_imagef(predWeightsFront, (int4)(visiblePosition.x, visiblePosition.y, wi, 0), (float4)(weight));
			}
		}

	for (int dx = -feedBackRadius; dx <= feedBackRadius; dx++)
		for (int dy = -feedBackRadius; dy <= feedBackRadius; dy++) {
			int2 feedBackPosition = feedBackPositionCenter + (int2)(dx, dy);

			if (inBounds0(feedBackPosition, feedBackSize)) {
				int2 offset = feedBackPosition - feedBackFieldLowerBound;

				int wi = offset.y + offset.x * (feedBackRadius * 2 + 1);

				float weightPrev = read_imagef(feedBackWeightsBack, (int4)(visiblePosition.x, visiblePosition.y, wi, 0)).x;

				float statePrev = read_imagef(feedBackStatesPrev, hiddenPosition).x;

				float weight = weightPrev + weightAlpha * error * statePrev;

				write_imagef(feedBackWeightsBack, (int4)(visiblePosition.x, visiblePosition.y, wi, 0), (float4)(weight));
			}
		}
}